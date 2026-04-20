//
//  ContainerDetailsViewModel.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 22.03.2026.
//

import Combine
import UIKit
import Foundation

@MainActor
final class ContainerDetailsViewModel: ObservableObject {

    // MARK: - Properties

    @Published var container: Container
    @Published var showDeleteAlert = false
    @Published var showShareSheet = false
    @Published var showHistorySheet = false
    @Published var isError = false

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

    var recipients: [Recipient] = [
        .init(id: "1", name: "Петя Иванов", publicKey: "GK4gR7f8gF", isVerified: true),
        .init(id: "2", name: "Петя Иванов", publicKey: "GK4gR7f8gF", isVerified: false),
        .init(id: "3", name: "Петя Иванов", publicKey: "GK4gR7f8gF", isVerified: true),
        .init(id: "4", name: "Петя Иванов", publicKey: "GK4gR7f8gF", isVerified: false),
        .init(id: "5", name: "Петя Иванов", publicKey: "GK4gR7f8gF", isVerified: true),
        .init(id: "6", name: "Петя Иванов", publicKey: "GK4gR7f8gF", isVerified: false),
        .init(id: "7", name: "Петя Иванов", publicKey: "GK4gR7f8gF", isVerified: true),
    ]

    private let coordinator: ContainersCoordinatorProtocol

    // MARK: - Init

    init(coordinator: ContainersCoordinatorProtocol, container: Container) {
        self.coordinator = coordinator
        self.container = container
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

    func copyContainerToSelf() {
        // TODO: - Copy container to self
    }

    func confirmDelete() {
        showDeleteAlert = true
    }

    func deleteContainer() {
        Task {
            await coordinator.finish()
        }
    }
}
