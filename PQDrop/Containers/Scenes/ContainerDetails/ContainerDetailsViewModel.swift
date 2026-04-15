//
//  ContainerDetailsViewModel.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 22.03.2026.
//

import Combine
import UIKit

@MainActor
final class ContainerDetailsViewModel: ObservableObject {

    // MARK: - Properties

    @Published var container: Container
    @Published var showDeleteAlert = false
    @Published var showShareSheet = false
    @Published var isError = false

    var isAvailable: Bool { container.isAvailable }
    var isCreated: Bool { container.isCreated }

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
        UIPasteboard.general.string = container.id
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
        // TODO: - Navigate to container history screen
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
