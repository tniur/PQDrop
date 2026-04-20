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

    var hasSelection: Bool {
        !selectedContactIds.isEmpty
    }

    private var idsToGrant: Set<String> {
        selectedContactIds.subtracting(hasAccessContactIds)
    }

    private let coordinator: ContainersCoordinatorProtocol
    private let containerService: ContainerService
    private let contactRepository: ContactRepository
    private let historyRepository: HistoryRepository
    private var contactPublicKeys: [String: Data] = [:]

    // MARK: - Init
    
    init(
        coordinator: ContainersCoordinatorProtocol,
        container: Container,
        containerService: ContainerService,
        contactRepository: ContactRepository,
        historyRepository: HistoryRepository
    ) {
        self.coordinator = coordinator
        self.container = container
        self.containerService = containerService
        self.contactRepository = contactRepository
        self.historyRepository = historyRepository

        loadContacts()
    }

    // MARK: - Methods

    func isSelected(_ id: String) -> Bool {
        selectedContactIds.contains(id)
    }

    func hasAccess(_ id: String) -> Bool {
        hasAccessContactIds.contains(id)
    }

    func toggleContact(_ id: String) {
        guard !hasAccessContactIds.contains(id) else { return }

        if selectedContactIds.contains(id) {
            selectedContactIds.remove(id)
        } else {
            selectedContactIds.insert(id)
        }
    }

    func addContact() {
        guard hasSelection else {
            activeAlert = .noSelection
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
        guard let fileURL = container.fileURL else { return }

        isProcessing = true

        Task {
            do {
                let info = try containerService.inspectContainer(at: fileURL)

                var recipientKeys: [XWing.PublicKey] = info.recipientKeyIds.compactMap { fingerprint in
                    try? XWing.PublicKey(rawRepresentation: fingerprint.rawValue)
                }

                for contactId in idsToGrant {
                    guard let keyData = contactPublicKeys[contactId],
                          let publicKey = try? XWing.PublicKey(rawRepresentation: keyData) else {
                        continue
                    }
                    if !recipientKeys.contains(publicKey) {
                        recipientKeys.append(publicKey)
                    }
                }

                let tempURL = FileManager.default.temporaryDirectory
                    .appendingPathComponent(UUID().uuidString)
                    .appendingPathExtension("pqck")

                try await Task.detached {
                    try self.containerService.rekeyContainer(
                        at: fileURL,
                        to: tempURL,
                        remainingRecipients: recipientKeys
                    )
                }.value

                try FileManager.default.removeItem(at: fileURL)
                try FileManager.default.moveItem(at: tempURL, to: fileURL)

                for contactId in idsToGrant {
                    let contactName = contacts.first(where: { $0.id == contactId })?.name ?? ""
                    try? historyRepository.append(
                        type: .accessGranted,
                        containerID: container.containerID,
                        containerName: container.name,
                        detail: contactName
                    )
                }

                hasAccessContactIds.formUnion(idsToGrant)
                selectedContactIds.removeAll()
                isProcessing = false
            } catch {
                isProcessing = false
            }
        }
    }

    func requestRevokeAccess(for id: String) {
        guard hasAccessContactIds.contains(id) else { return }
        activeAlert = .revokeAccess(contactId: id)
    }

    func revokeAccess(for id: String) {
        activeAlert = nil
        guard let fileURL = container.fileURL else { return }

        isProcessing = true

        Task {
            do {
                let info = try containerService.inspectContainer(at: fileURL)

                guard let revokedKeyData = contactPublicKeys[id],
                      let revokedKey = try? XWing.PublicKey(rawRepresentation: revokedKeyData) else {
                    isProcessing = false
                    return
                }

                let revokedFingerprint = revokedKey.fingerprint

                let remainingKeys: [XWing.PublicKey] = info.recipientKeyIds.compactMap { fingerprint in
                    guard fingerprint != revokedFingerprint else { return nil }
                    return try? XWing.PublicKey(rawRepresentation: fingerprint.rawValue)
                }

                let tempURL = FileManager.default.temporaryDirectory
                    .appendingPathComponent(UUID().uuidString)
                    .appendingPathExtension("pqck")

                try await Task.detached {
                    try self.containerService.rekeyContainer(
                        at: fileURL,
                        to: tempURL,
                        remainingRecipients: remainingKeys
                    )
                }.value

                try FileManager.default.removeItem(at: fileURL)
                try FileManager.default.moveItem(at: tempURL, to: fileURL)

                let contactName = contacts.first(where: { $0.id == id })?.name ?? ""
                try? historyRepository.append(
                    type: .accessRevoked,
                    containerID: container.containerID,
                    containerName: container.name,
                    detail: contactName
                )

                hasAccessContactIds.remove(id)
                selectedContactIds.remove(id)
                isProcessing = false
            } catch {
                isProcessing = false
            }
        }
    }

    private func loadContacts() {
        let allContacts = contactRepository.fetchAll()

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
    }
}
