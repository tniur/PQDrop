//
//  AccessControlViewModel.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 22.03.2026.
//

import Foundation
import Combine
import PQContainerKit

@MainActor
final class AccessControlViewModel: ObservableObject {

    // MARK: - Properties

    @Published var container: Container
    @Published var hasAccessContactIds: Set<String> = []
    @Published var selectedContactIds: Set<String> = []
    @Published var activeAlert: AccessControlAlert?
    @Published var currentAccessRecipients: [Recipient] = []
    @Published var availableContacts: [Recipient] = []
    @Published var isProcessing = false

    var hasUnsavedChanges: Bool {
        selectedContactIds != hasAccessContactIds
    }

    var visibleRecipients: [Recipient] {
        currentAccessRecipients + availableContacts
    }

    var visibleRecipientsCount: Int {
        visibleRecipients.count
    }

    private var idsToGrant: Set<String> {
        selectedContactIds.subtracting(hasAccessContactIds)
    }

    private var idsToRevoke: Set<String> {
        hasAccessContactIds.subtracting(selectedContactIds)
    }

    private let coordinator: ContainersCoordinatorProtocol
    private let containerService: ContainerService
    private let contactRepository: ContactRepository
    private let containerRepository: ContainerRepository
    private let historyRepository: HistoryRepository
    private let keyPairManager: KeyPairManager
    private var contactPublicKeys: [String: Data] = [:]

    // MARK: - Init
    
    init(
        coordinator: ContainersCoordinatorProtocol,
        container: Container,
        containerService: ContainerService,
        contactRepository: ContactRepository,
        containerRepository: ContainerRepository,
        historyRepository: HistoryRepository,
        keyPairManager: KeyPairManager
    ) {
        self.coordinator = coordinator
        self.container = container
        self.containerService = containerService
        self.contactRepository = contactRepository
        self.containerRepository = containerRepository
        self.historyRepository = historyRepository
        self.keyPairManager = keyPairManager

        loadContacts()
    }

    // MARK: - Methods

    func isSelected(_ id: String) -> Bool {
        selectedContactIds.contains(id)
    }

    func toggleContact(_ id: String) {
        if selectedContactIds.contains(id) {
            selectedContactIds.remove(id)
        } else {
            selectedContactIds.insert(id)
        }
    }

    func editName() {
        Task {
            await coordinator.showEditContainerName(mode: .edit(container: container))
        }
    }

    func confirmSaveChanges() {
        guard hasUnsavedChanges else {
            return
        }

        let hasUnverified = idsToGrant.contains { id in
            visibleRecipients.first(where: { $0.id == id })?.isVerified == false
        }

        if hasUnverified {
            activeAlert = .unverifiedWarning
        } else {
            activeAlert = .applyAccessChanges
        }
    }

    func applySelectedContacts() {
        activeAlert = nil

        let idsToGrant = self.idsToGrant
        let idsToRevoke = self.idsToRevoke

        guard let fileURL = container.fileURL else { return }

        isProcessing = true

        Task {
            do {
                let info = try containerService.inspectContainer(at: fileURL)
                let privateKey = try loadPrivateKeyForRekey(info: info)
                let recipientKeys = deduplicatedRecipientKeys(try selectedRecipientKeys())

                let tempURL = FileManager.default.temporaryDirectory
                    .appendingPathComponent(UUID().uuidString)
                    .appendingPathExtension("pqck")
                defer {
                    try? FileManager.default.removeItem(at: tempURL)
                }

                try await Task.detached {
                    try self.containerService.rekeyContainer(
                        at: fileURL,
                        to: tempURL,
                        remainingRecipients: recipientKeys,
                        privateKey: privateKey
                    )
                }.value

                try verifyRecipients(at: tempURL, recipientKeys: recipientKeys, ownerKey: privateKey.publicKey)
                try replaceContainerFile(at: fileURL, with: tempURL)
                let storedRecipientPublicKeysRaw = recipientKeys.map(\.rawRepresentation)
                try? containerRepository.updateRecipientPublicKeys(storedRecipientPublicKeysRaw, for: container.id)
                container.recipientPublicKeysRaw = storedRecipientPublicKeysRaw

                for contactId in idsToGrant {
                    try? historyRepository.append(
                        type: .accessGranted,
                        containerID: container.containerID,
                        containerName: container.name,
                        detail: recipientName(for: contactId)
                    )
                }

                for contactId in idsToRevoke {
                    try? historyRepository.append(
                        type: .accessRevoked,
                        containerID: container.containerID,
                        containerName: container.name,
                        detail: recipientName(for: contactId)
                    )
                }

                loadContacts()
                isProcessing = false
            } catch {
                isProcessing = false
                activeAlert = .operationFailed(message: accessUpdateErrorMessage(error))
            }
        }
    }

    private func loadContacts() {
        let ownPublicKeyRaw = try? keyPairManager.loadOrMigratePublicKey()?.rawRepresentation
        let allContacts = contactRepository.fetchAll().filter { contact in
            guard let ownPublicKeyRaw else {
                return true
            }

            return contact.publicKeyRaw != ownPublicKeyRaw
        }

        hasAccessContactIds.removeAll()
        selectedContactIds.removeAll()
        contactPublicKeys.removeAll()
        currentAccessRecipients = []
        availableContacts = []

        var localRecipients: [Recipient] = []
        var localRecipientsByID: [String: Recipient] = [:]

        for contact in allContacts {
            let fingerprint = Fingerprint.fromPublicKeyRaw(contact.publicKeyRaw)
            let recipientID = recipientID(for: fingerprint)

            guard localRecipientsByID[recipientID] == nil else {
                continue
            }

            contactPublicKeys[recipientID] = contact.publicKeyRaw

            let recipient = Recipient(
                id: recipientID,
                name: contact.name,
                fingerprint: fingerprint.hexStringGrouped,
                isVerified: contact.isVerified,
                isManageable: true
            )

            localRecipients.append(recipient)
            localRecipientsByID[recipientID] = recipient
        }

        var storedRecipientKeysByID: [String: Data] = [:]
        for rawPublicKey in container.recipientPublicKeysRaw {
            guard let publicKey = try? XWing.PublicKey(rawRepresentation: rawPublicKey) else {
                continue
            }

            let recipientID = recipientID(for: publicKey.fingerprint)

            if storedRecipientKeysByID[recipientID] == nil {
                storedRecipientKeysByID[recipientID] = rawPublicKey
            }
        }

        guard let fileURL = container.fileURL else {
            availableContacts = makeAvailableContacts(from: localRecipients, excluding: [])
            return
        }

        persistRecoveredRecipientKeysIfNeeded(fileURL: fileURL, contacts: allContacts)

        do {
            let info = try containerService.inspectContainer(at: fileURL)
            let ownerFingerprint = ownPublicKeyRaw.map(Fingerprint.fromPublicKeyRaw)
            var currentRecipientIDs: Set<String> = []
            var currentRecipients: [Recipient] = []

            for fingerprint in info.recipientKeyIds where fingerprint != ownerFingerprint {
                let recipientID = recipientID(for: fingerprint)
                currentRecipientIDs.insert(recipientID)

                if let localRecipient = localRecipientsByID[recipientID] {
                    currentRecipients.append(localRecipient)
                    continue
                }

                if let rawPublicKey = storedRecipientKeysByID[recipientID] {
                    contactPublicKeys[recipientID] = rawPublicKey
                    currentRecipients.append(
                        Recipient(
                            id: recipientID,
                            name: String(localized: "contacts.unknown"),
                            fingerprint: fingerprint.hexStringGrouped,
                            isVerified: false,
                            isManageable: true
                        )
                    )
                    continue
                }

                currentRecipients.append(
                    Recipient(
                        id: recipientID,
                        name: String(localized: "contacts.unknown"),
                        fingerprint: fingerprint.hexStringGrouped,
                        isVerified: false,
                        isManageable: false
                    )
                )
            }

            hasAccessContactIds = currentRecipientIDs
            selectedContactIds = currentRecipientIDs
            currentAccessRecipients = currentRecipients
            availableContacts = makeAvailableContacts(from: localRecipients, excluding: currentRecipientIDs)
        } catch {
            availableContacts = makeAvailableContacts(from: localRecipients, excluding: [])
        }
    }

    private func selectedRecipientKeys() throws -> [XWing.PublicKey] {
        try selectedContactIds.map(publicKey(for:))
    }

    private func publicKey(for contactId: String) throws -> XWing.PublicKey {
        guard contactPublicKeys[contactId] != nil else {
            throw ContainerServiceError.recipientKeysUnavailable
        }

        guard let keyData = contactPublicKeys[contactId],
              let publicKey = try? XWing.PublicKey(rawRepresentation: keyData) else {
            throw AccessUpdateError.contactKeyUnavailable
        }

        return publicKey
    }

    private func loadPrivateKeyForRekey(info: ContainerInfo) throws -> XWing.PrivateKey {
        guard let privateKey = try keyPairManager.loadPrivateKey() else {
            throw AccessUpdateError.noKeyPair
        }

        guard info.containsRecipient(privateKey.publicKey) else {
            throw AccessUpdateError.currentKeyHasNoAccess
        }

        return privateKey
    }

    private func verifyRecipients(
        at fileURL: URL,
        recipientKeys: [XWing.PublicKey],
        ownerKey: XWing.PublicKey
    ) throws {
        let info = try containerService.inspectContainer(at: fileURL)
        let actualFingerprints = Set(info.recipientKeyIds)
        let expectedFingerprints = Set(([ownerKey] + recipientKeys).map(\.fingerprint))

        guard expectedFingerprints.isSubset(of: actualFingerprints) else {
            throw AccessUpdateError.verificationFailed
        }
    }

    private func replaceContainerFile(at fileURL: URL, with tempURL: URL) throws {
        let backupURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("pqck")

        try FileManager.default.moveItem(at: fileURL, to: backupURL)

        do {
            try FileManager.default.moveItem(at: tempURL, to: fileURL)
            try? FileManager.default.removeItem(at: backupURL)
        } catch {
            try? FileManager.default.moveItem(at: backupURL, to: fileURL)
            throw error
        }
    }

    private func makeAvailableContacts(
        from contacts: [Recipient],
        excluding recipientIDs: Set<String>
    ) -> [Recipient] {
        contacts.filter { !recipientIDs.contains($0.id) }
    }

    private func recipientName(for contactId: String) -> String {
        guard let recipient = visibleRecipients.first(where: { $0.id == contactId }) else {
            return String(localized: "contacts.unknown")
        }

        let unknownName = String(localized: "contacts.unknown")
        guard recipient.name == unknownName else {
            return recipient.name
        }

        return "\(unknownName) (\(recipient.shortFingerprint))"
    }

    private func recipientID(for fingerprint: Fingerprint) -> String {
        fingerprint.rawValue.map { String(format: "%02x", $0) }.joined()
    }

    private func deduplicatedRecipientKeys(_ recipients: [XWing.PublicKey]) -> [XWing.PublicKey] {
        var seenFingerprints: Set<Fingerprint> = []
        var uniqueRecipients: [XWing.PublicKey] = []

        for recipient in recipients where seenFingerprints.insert(recipient.fingerprint).inserted {
            uniqueRecipients.append(recipient)
        }

        return uniqueRecipients
    }

    private func accessUpdateErrorMessage(_ error: Error) -> String {
        if let accessError = error as? AccessUpdateError {
            switch accessError {
            case .noKeyPair:
                return String(localized: "containers.access.error.no.key.pair")
            case .currentKeyHasNoAccess:
                return String(localized: "containers.access.error.current.key.has.no.access")
            case .contactKeyUnavailable:
                return String(localized: "containers.access.error.contact.key.unavailable")
            case .verificationFailed:
                return String(localized: "containers.access.error.verification.failed")
            }
        }

        if let serviceError = error as? ContainerServiceError {
            switch serviceError {
            case .noKeyPair:
                return String(localized: "containers.access.error.no.key.pair")
            case .recipientKeysUnavailable:
                return String(localized: "containers.access.error.recipient.keys.unavailable")
            }
        }

        if let containerError = error as? ContainerError {
            switch containerError {
            case .accessDenied:
                return String(localized: "containers.access.error.access.denied")
            case .invalidFormat, .unsupportedVersion:
                return String(localized: "containers.access.error.invalid.format")
            case .limitsExceeded:
                return String(localized: "containers.access.error.limits.exceeded")
            case .ioError:
                return String(localized: "containers.access.error.io")
            case .cannotOpen:
                return String(localized: "containers.access.error.cannot.open")
            }
        }

        return String(localized: "containers.access.error.generic")
    }

    private func persistRecoveredRecipientKeysIfNeeded(fileURL: URL, contacts: [Contact]) {
        guard let recoveredRawKeys = try? containerService.mergedCurrentNonOwnerRecipientPublicKeys(
            at: fileURL,
            storedRecipientPublicKeysRaw: container.recipientPublicKeysRaw,
            candidateRecipientPublicKeysRaw: contacts.map(\.publicKeyRaw)
        ) else {
            return
        }

        guard recoveredRawKeys != container.recipientPublicKeysRaw else {
            return
        }

        try? containerRepository.updateRecipientPublicKeys(recoveredRawKeys, for: container.id)
        container.recipientPublicKeysRaw = recoveredRawKeys
    }
}

private enum AccessUpdateError: Error {
    case noKeyPair
    case currentKeyHasNoAccess
    case contactKeyUnavailable
    case verificationFailed
}
