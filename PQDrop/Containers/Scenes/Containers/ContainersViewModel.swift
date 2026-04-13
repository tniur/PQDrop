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
    @Published var selectedTab: ContainersTab = .created
    @Published var containerToDelete: Container? = nil

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

    private var containers: [Container] = [
        .init(id: "100000001", name: "Название контейнера", isAvailable: true, isCreated: true),
        .init(id: "100000002", name: "Название контейнера", isAvailable: true, isCreated: true),
        .init(id: "100000003", name: "Название контейнера", isAvailable: false, isCreated: true),
        .init(id: "100000004", name: "Название контейнера", isAvailable: true, isCreated: true),
        .init(id: "200000005", name: "Полученный контейнер", isAvailable: true, isCreated: false),
        .init(id: "200000006", name: "Полученный контейнер", isAvailable: true, isCreated: false),
        .init(id: "200000007", name: "Полученный контейнер", isAvailable: true, isCreated: false),
        .init(id: "200000008", name: "Полученный контейнер", isAvailable: true, isCreated: false),
        .init(id: "200000009", name: "Полученный контейнер", isAvailable: true, isCreated: false),
        .init(id: "200000010", name: "Полученный контейнер", isAvailable: true, isCreated: false),
        .init(id: "200000011", name: "Полученный контейнер", isAvailable: true, isCreated: false),
        .init(id: "200000012", name: "Полученный контейнер", isAvailable: true, isCreated: false),
        .init(id: "200000013", name: "Полученный контейнер", isAvailable: true, isCreated: false),
        .init(id: "200000014", name: "Полученный контейнер", isAvailable: true, isCreated: false),
        .init(id: "200000015", name: "Полученный контейнер", isAvailable: true, isCreated: false),
        .init(id: "200000016", name: "Полученный контейнер", isAvailable: false, isCreated: false)
    ]

    private let coordinator: ContainersCoordinatorProtocol

    // MARK: - Initializer

    init(coordinator: ContainersCoordinatorProtocol) {
        self.coordinator = coordinator
    }

    // MARK: - Methods

    func delete(container: Container) {
        containers.removeAll { $0.id == container.id }
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
        // TODO: - Navigate to import container flow
    }

    func showContainerDetails(container: Container) {
        Task {
            await coordinator.showContainerDetails(with: container)
        }
    }
}
