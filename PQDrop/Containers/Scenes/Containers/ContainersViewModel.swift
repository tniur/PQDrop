//
//  ContainersViewModel.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 20.03.2026.
//

import Combine
import Foundation

@MainActor
final class ContainersViewModel: ObservableObject {

    // MARK: - Properties

    @Published var searchText: String = ""
    @Published var selectedTab: ContainersTab = .created {
        didSet {
            ContainersMockStore.preferredTab = selectedTab
        }
    }
    @Published var containerToDelete: Container? = nil
    @Published var isFileImporterPresented = false

    @Published private var containers: [Container]

    var filteredContainers: [Container] {
        let tabFiltered: [Container]
        switch selectedTab {
        case .created:
            tabFiltered = containers.filter { $0.isCreated }
        case .received:
            tabFiltered = containers.filter { !$0.isCreated }
        }

        guard !searchText.isEmpty else { return tabFiltered }
        return tabFiltered.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.id.localizedCaseInsensitiveContains(searchText)
        }
    }

    var isSearchActive: Bool {
        !searchText.isEmpty
    }

    private let coordinator: ContainersCoordinatorProtocol

    // MARK: - Initializer

    init(coordinator: ContainersCoordinatorProtocol) {
        self.coordinator = coordinator
        containers = ContainersMockStore.containers
        selectedTab = ContainersMockStore.preferredTab
    }

    // MARK: - Methods

    func delete(container: Container) {
        ContainersMockStore.delete(container: container)
        containers = ContainersMockStore.containers
    }

    func emptyTabAction() {
        switch selectedTab {
        case .created:
            createContainer()
        case .received:
            importContainer()
        }
    }

    func createContainer() {
        Task {
            await coordinator.showEditContainerName(mode: .create)
        }
    }

    func importContainer() {
        isFileImporterPresented = true
    }

    func handleImportedFile(url: URL?) {
        guard let url else { return }

        Task {
            await coordinator.showImportContainerValidation(fileURL: url)
        }
    }

    func showContainerDetails(container: Container) {
        Task {
            await coordinator.showContainerDetails(with: container)
        }
    }
}
