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
        let idsToGrant = self.idsToGrant

        guard !idsToGrant.isEmpty else {
            activeAlert = .noSelection
            return
        }

        guard let fileURL = container.fileURL else { return }

        isProcessing = true

        Task {
            do {
                let info = try containerService.inspectContainer(at: fileURL)
                let privateKey = try loadPrivateKeyForRekey(info: info)

                var recipientKeys = knownContactKeys(in: info.recipientKeyIds)

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

                hasAccessContactIds.formUnion(idsToGrant)
                selectedContactIds.removeAll()
                reloadAccessState()
                isProcessing = false
            } catch {
                isProcessing = false
                activeAlert = .operationFailed(message: accessUpdateErrorMessage(error))
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
                let privateKey = try loadPrivateKeyForRekey(info: info)

                guard let revokedKeyData = contactPublicKeys[id],
                      let revokedKey = try? XWing.PublicKey(rawRepresentation: revokedKeyData) else {
                    throw AccessUpdateError.contactKeyUnavailable
                }

                let revokedFingerprint = revokedKey.fingerprint

                let remainingKeys = knownContactKeys(in: info.recipientKeyIds).filter { publicKey in
                    publicKey.fingerprint != revokedFingerprint
                }

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
                        remainingRecipients: remainingKeys,
                        privateKey: privateKey
                    )
                }.value

                try verifyRecipients(at: tempURL, recipientKeys: remainingKeys, ownerKey: privateKey.publicKey)
                try replaceContainerFile(at: fileURL, with: tempURL)

                let contactName = contacts.first(where: { $0.id == id })?.name ?? ""
                try? historyRepository.append(
                    type: .accessRevoked,
                    containerID: container.containerID,
                    containerName: container.name,
                    detail: contactName
                )

                hasAccessContactIds.remove(id)
                selectedContactIds.remove(id)
                reloadAccessState()
                isProcessing = false
            } catch {
                isProcessing = false
                activeAlert = .operationFailed(message: accessUpdateErrorMessage(error))
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

    private func knownContactKeys(in recipientKeyIds: [Fingerprint]) -> [XWing.PublicKey] {
        let recipientFingerprints = Set(recipientKeyIds)

        return contactPublicKeys.values.compactMap { rawPublicKey in
            guard let publicKey = try? XWing.PublicKey(rawRepresentation: rawPublicKey),
                  recipientFingerprints.contains(publicKey.fingerprint) else {
                return nil
            }

            return publicKey
        }
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
                return "Не найден ключ шифрования. Проверьте профиль и повторите действие."
            case .currentKeyHasNoAccess:
                return "Текущий ключ не является получателем этого контейнера. Поэтому приложение не может изменить список доступа."
            case .contactKeyUnavailable:
                return "Не удалось прочитать публичный ключ выбранного контакта."
            case .verificationFailed:
                return "Контейнер был обновлен, но проверка нового списка получателей не прошла. Исходный файл сохранен без изменений."
            }
        }

        if let containerError = error as? ContainerError {
            switch containerError {
            case .accessDenied:
                return "У текущего ключа нет доступа к этому контейнеру. Изменить получателей может только ключ, который уже есть в контейнере."
            case .invalidFormat, .unsupportedVersion:
                return "Файл контейнера имеет неподдерживаемый или поврежденный формат."
            case .limitsExceeded:
                return "В контейнере превышен лимит получателей."
            case .ioError:
                return "Не удалось записать обновленный файл контейнера."
            case .cannotOpen:
                return "Не удалось открыть контейнер для изменения доступа."
            }
        }

        return "Не удалось обновить контейнер. Проверьте, что файл доступен, и повторите действие."
    }
}

private enum AccessUpdateError: Error {
    case noKeyPair
    case currentKeyHasNoAccess
    case contactKeyUnavailable
    case verificationFailed
}
