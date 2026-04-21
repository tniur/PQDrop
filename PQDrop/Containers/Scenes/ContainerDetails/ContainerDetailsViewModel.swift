//
//  ContainerDetailsViewModel.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 22.03.2026.
//

import Combine
import UIKit
import Foundation
import PQContainerKit

@MainActor
final class ContainerDetailsViewModel: ObservableObject {

    // MARK: - Properties

    @Published var container: Container
    @Published var showDeleteAlert = false
    @Published var showShareSheet = false
    @Published var showHistorySheet = false
    @Published var isError = false
    @Published var recipients: [Recipient] = []
    @Published var isOpening = false

    var isAvailable: Bool { container.isAvailable }
    var isOwned: Bool { container.isOwned }

    var historyEvents: [HistoryEvent] {
        guard isOwned, isAvailable else { return [] }

        let calendar = Calendar.current
        let baseDate = calendar.date(from: DateComponents(year: 2026, month: 3, day: 20))!

        return [
            .init(
                id: UUID(),
                type: .export,
                containerName: container.name,
                containerID: container.containerID,
                detail: nil,
                timestamp: calendar.date(bySettingHour: 12, minute: 9, second: 0, of: baseDate)!
            ),
            .init(
                id: UUID(),
                type: .imported,
                containerName: container.name,
                containerID: container.containerID,
                detail: nil,
                timestamp: calendar.date(bySettingHour: 11, minute: 11, second: 0, of: baseDate)!
            ),
            .init(
                id: UUID(),
                type: .accessGranted,
                containerName: container.name,
                containerID: container.containerID,
                detail: nil,
                timestamp: calendar.date(bySettingHour: 10, minute: 12, second: 0, of: baseDate)!
            )
        ]
    }

    private let coordinator: ContainersCoordinatorProtocol
    private let containerService: ContainerService
    private let contactRepository: ContactRepository
    private let containerRepository: ContainerRepository
    private let historyRepository: HistoryRepository
    private let keyPairManager: KeyPairManager

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

        loadRecipients()
    }

    // MARK: - Methods

    func copyId() {
        UIPasteboard.general.string = container.id.uuidString
    }

    func editName() {
        Task {
            await coordinator.showEditContainerName(mode: .edit(container: container))
        }
    }

    func openContainer() {
        guard !isOpening else { return }

        guard let fileURL = container.fileURL else {
            isError = true
            return
        }

        guard let privateKey = try? keyPairManager.loadPrivateKey() else {
            isError = true
            return
        }

        let containerService = self.containerService
        let baseContainer = container
        let outputDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("decrypted_\(UUID().uuidString)")

        isOpening = true

        Task {
            do {
                let fileURLs = try await Task.detached {
                    try containerService.decryptContainer(
                        at: fileURL,
                        to: outputDir,
                        privateKey: privateKey
                    )
                }.value

                var openedContainer = baseContainer
                openedContainer.files = Self.makeFileItems(from: fileURLs)

                isOpening = false
                await coordinator.showContainerContents(with: openedContainer, decryptedDir: outputDir)
            } catch {
                try? FileManager.default.removeItem(at: outputDir)
                isOpening = false
                isError = true
            }
        }
    }

    func exportContainer() {
        showShareSheet = true
        try? historyRepository.append(
            type: .export,
            containerID: container.containerID,
            containerName: container.name
        )
    }

    func showRecipients() {
        Task {
            await coordinator.showRecipientsSheet(recipients: recipients)
        }
    }

    func showAccessManagement() {
        Task {
            await coordinator.showAccessControl(with: container)
        }
    }

    func showContainerHistory() {
        showHistorySheet = true
    }

    func showAllHistory() {
        showHistorySheet = false
        NotificationCenter.default.post(
            name: .mainTabSelectionRequested,
            object: MainTabPage.history
        )
    }

    @Published var isCopying = false

    func copyContainerToSelf() {
        guard let fileURL = container.fileURL else { return }
        guard let privateKey = try? keyPairManager.loadPrivateKey() else { return }

        let containerName = container.name
        let containerService = self.containerService

        isCopying = true

        Task {
            do {
                let tempDir = FileManager.default.temporaryDirectory
                    .appendingPathComponent("copy_\(UUID().uuidString)")

                let fileURLs = try await Task.detached {
                    try containerService.decryptContainer(
                        at: fileURL,
                        to: tempDir,
                        privateKey: privateKey
                    )
                }.value

                let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let containersDir = documentsDir.appendingPathComponent("Containers")
                try FileManager.default.createDirectory(at: containersDir, withIntermediateDirectories: true)

                let result = try await Task.detached {
                    try containerService.createContainer(
                        name: containerName,
                        files: fileURLs,
                        recipients: [],
                        destinationDir: containersDir
                    )
                }.value

                try? FileManager.default.removeItem(at: tempDir)

                _ = try containerRepository.create(
                    name: containerName,
                    containerID: result.containerID,
                    fileURL: result.fileURL,
                    isOwned: true,
                    isAvailable: true
                )

                try? historyRepository.append(
                    type: .imported,
                    containerID: result.containerID,
                    containerName: containerName
                )

                isCopying = false
                await coordinator.finish()
            } catch {
                isCopying = false
            }
        }
    }

    func confirmDelete() {
        showDeleteAlert = true
    }

    func deleteContainer() {
        if let fileURL = container.fileURL {
            try? FileManager.default.removeItem(at: fileURL)
        }

        try? containerRepository.delete(by: container.id)

        Task {
            await coordinator.finish()
        }
    }

    func reload() {
        if let updated = containerRepository.fetch(by: container.id) {
            container = updated
        }

        loadRecipients()
    }

    private func loadRecipients() {
        guard let fileURL = container.fileURL else {
            recipients = []
            return
        }

        let ownerFingerprint = (try? keyPairManager.loadPublicKey())?.fingerprint

        do {
            let info = try containerService.inspectContainer(at: fileURL)
            let contacts = contactRepository.fetchAll()

            recipients = info.recipientKeyIds.map { fingerprint in
                let hexFingerprint = fingerprint.rawValue.map { String(format: "%02x", $0) }.joined()

                if fingerprint == ownerFingerprint {
                    return Recipient(
                        id: hexFingerprint,
                        name: "Вы",
                        fingerprint: hexFingerprint,
                        isVerified: true
                    )
                }

                let matchedContact = contacts.first { contact in
                    Fingerprint.fromPublicKeyRaw(contact.publicKeyRaw) == fingerprint
                }

                return Recipient(
                    id: hexFingerprint,
                    name: matchedContact?.name ?? "Неизвестный",
                    fingerprint: hexFingerprint,
                    isVerified: matchedContact?.isVerified ?? false
                )
            }
        } catch {
            recipients = []
        }
    }

    private static func makeFileItems(from urls: [URL]) -> [ContainerFileItem] {
        urls.map { url in
            let values = try? url.resourceValues(forKeys: [.fileSizeKey])
            let fileSize = Int64(values?.fileSize ?? 0)
            let sizeText = ByteCountFormatter.string(fromByteCount: fileSize, countStyle: .file)

            return ContainerFileItem(
                id: UUID().uuidString,
                name: url.lastPathComponent,
                sizeText: sizeText,
                localURL: url
            )
        }
    }
}
