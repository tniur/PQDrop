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

    // MARK: - Init
    
    init(
        coordinator: ContainersCoordinatorProtocol,
        container: Container,
        containerService: ContainerService,
        contactRepository: ContactRepository
    ) {
        self.coordinator = coordinator
        self.container = container
        self.containerService = containerService
        self.contactRepository = contactRepository

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
        Task {
            await coordinator.showContainerContents(with: container)
        }
    }

    func exportContainer() {
        showShareSheet = true
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

    func copyContainerToSelf() {}

    func confirmDelete() {
        showDeleteAlert = true
    }

    func deleteContainer() {
        Task {
            await coordinator.finish()
        }
    }

    private func loadRecipients() {
        guard let fileURL = container.fileURL else {
            recipients = []
            return
        }

        do {
            let info = try containerService.inspectContainer(at: fileURL)
            let contacts = contactRepository.fetchAll()

            recipients = info.recipientKeyIds.map { fingerprint in
                let hexFingerprint = fingerprint.rawValue.map { String(format: "%02x", $0) }.joined()

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
}
