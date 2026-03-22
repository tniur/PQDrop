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
        // TODO: - Navigate to edit name screen
    }

    func openContainer() {
        // TODO: - Navigate to open container screen
    }

    func exportContainer() {
        showShareSheet = true
    }

    func showRecipients() {
        // TODO: - Navigate to recipients screen
    }

    func showAccessManagement() {
        // TODO: - Navigate to access management screen
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
