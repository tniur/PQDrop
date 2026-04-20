//
//  EditContainerNameViewModel.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 13.04.2026.
//

import Combine
import Foundation

@MainActor
final class EditContainerNameViewModel: ObservableObject {

    // MARK: - Enums

    enum Mode {
        case create
        case edit(container: Container)
    }

    // MARK: - Properties

    @Published var name: String = ""

    var buttonTitle: String {
        switch mode {
        case .create:
            return "Далее"
        case .edit:
            return "Сохранить"
        }
    }

    private let mode: Mode
    private let coordinator: ContainersCoordinatorProtocol
    private let containerRepository: ContainerRepository

    // MARK: - Initializer

    init(
        coordinator: ContainersCoordinatorProtocol,
        mode: Mode,
        containerRepository: ContainerRepository = ContainerRepository()
    ) {
        self.coordinator = coordinator
        self.mode = mode
        self.containerRepository = containerRepository

        if case .edit(let container) = mode {
            name = container.name
        }
    }

    // MARK: - Methods

    func submit() {
        switch mode {
        case .create:
            Task {
                await coordinator.showCreateContainerFiles(name: name)
            }
        case .edit(let container):
            try? containerRepository.updateName(name, for: container.id)
            Task {
                await coordinator.pop()
            }
        }
    }
}
