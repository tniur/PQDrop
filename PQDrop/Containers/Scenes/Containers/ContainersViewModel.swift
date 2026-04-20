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

    @Published var searchText: String = ""
    @Published var selectedTab: ContainersTab = .created
    @Published var containerToDelete: Container? = nil
    @Published var isFileImporterPresented = false

    @Published private var containers: [Container] = []

    var filteredContainers: [Container] {
        let tabFiltered: [Container]
        switch selectedTab {
        case .created:
            tabFiltered = containers.filter { $0.isOwned }
        case .received:
            tabFiltered = containers.filter { !$0.isOwned }
        }

        guard !searchText.isEmpty else { return tabFiltered }
        return tabFiltered.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.id.uuidString.localizedCaseInsensitiveContains(searchText)
        }
    }

    var isSearchActive: Bool {
        !searchText.isEmpty
    }

    private let coordinator: ContainersCoordinatorProtocol
    private let containerRepository: ContainerRepository

    init(coordinator: ContainersCoordinatorProtocol, containerRepository: ContainerRepository) {
        self.coordinator = coordinator
        self.containerRepository = containerRepository
        loadContainers()
    }

    func loadContainers() {
        containers = containerRepository.fetchAll()
    }

    func delete(container: Container) {
        if let fileURL = container.fileURL {
            try? FileManager.default.removeItem(at: fileURL)
        }
        
        try? containerRepository.delete(by: container.id)
        
        loadContainers()
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
