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
    @Published var contacts: [Recipient] = []
    @Published var isProcessing = false

    var hasUnsavedChanges: Bool {
        selectedContactIds != hasAccessContactIds
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
    private let historyRepository: HistoryRepository
    private let keyPairManager: KeyPairManager
    private var contactPublicKeys: [String: Data] = [:]

    // MARK: - Init
    
    init(
        coordinator: ContainersCoordinatorProtocol,
        container: Container,
        containerService: ContainerService,
        contactRepository: ContactRepository,
        historyRepository: HistoryRepository,
        keyPairManager: KeyPairManager
    ) {
        self.coordinator = coordinator
        self.container = container
        self.containerService = containerService
        self.contactRepository = contactRepository
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

    func confirmSaveChanges() {
        guard hasUnsavedChanges else {
            return
        }

        let hasUnverified = idsToGrant.contains { id in
            contacts.first(where: { $0.id == id })?.isVerified == false
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
                let recipientKeys = try selectedContactIds.map(publicKey(for:))

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

                for contactId in idsToGrant {
                    let contactName = contacts.first(where: { $0.id == contactId })?.name ?? ""
                    try? historyRepository.append(
                        type: .accessGranted,
                        containerID: container.containerID,
                        containerName: container.name,
                        detail: contactName
                    )
                }

                for contactId in idsToRevoke {
                    let contactName = contacts.first(where: { $0.id == contactId })?.name ?? ""
                    try? historyRepository.append(
                        type: .accessRevoked,
                        containerID: container.containerID,
                        containerName: container.name,
                        detail: contactName
                    )
                }

                reloadAccessState()
                selectedContactIds = hasAccessContactIds
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

        contacts = allContacts.map { contact in
            let hexFingerprint = Fingerprint.fromPublicKeyRaw(contact.publicKeyRaw).hexStringGrouped
            let idString = contact.id.uuidString
            contactPublicKeys[idString] = contact.publicKeyRaw

            return Recipient(
                id: idString,
                name: contact.name,
                fingerprint: hexFingerprint,
                isVerified: contact.isVerified
            )
        }

        guard let fileURL = container.fileURL else { return }

        do {
            let info = try containerService.inspectContainer(at: fileURL)

            for contact in allContacts {
                let contactFingerprint = Fingerprint.fromPublicKeyRaw(contact.publicKeyRaw)
                if info.recipientKeyIds.contains(contactFingerprint) {
                    hasAccessContactIds.insert(contact.id.uuidString)
                }
            }
        } catch {}

        selectedContactIds = hasAccessContactIds
    }

    private func publicKey(for contactId: String) throws -> XWing.PublicKey {
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

    private func reloadAccessState() {
        guard let fileURL = container.fileURL,
              let info = try? containerService.inspectContainer(at: fileURL) else {
            return
        }

        hasAccessContactIds = Set(contactPublicKeys.compactMap { contactId, rawPublicKey in
            let fingerprint = Fingerprint.fromPublicKeyRaw(rawPublicKey)
            return info.recipientKeyIds.contains(fingerprint) ? contactId : nil
        })
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
}

private enum AccessUpdateError: Error {
    case noKeyPair
    case currentKeyHasNoAccess
    case contactKeyUnavailable
    case verificationFailed
}
