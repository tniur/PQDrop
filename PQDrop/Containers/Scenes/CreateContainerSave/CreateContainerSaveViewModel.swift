//
//  CreateContainerSaveViewModel.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 13.04.2026.
//

import Combine
import Foundation

@MainActor
final class CreateContainerSaveViewModel: ObservableObject {

    // MARK: - Enums

    enum Phase: Equatable {
        case loading
        case success
        case failure
    }

    // MARK: - Properties

    @Published var phase: Phase = .loading
    @Published var status: CreateContainerStatus = .preparingFiles

    private var uiTask: Task<Void, Never>?
    private var workTask: Task<Void, Never>?

    private let coordinator: ContainersCoordinatorProtocol
    private let name: String
    private let files: [ContainerFileItem]

    // MARK: - Initializer

    init(coordinator: ContainersCoordinatorProtocol, name: String, files: [ContainerFileItem]) {
        self.coordinator = coordinator
        self.name = name
        self.files = files
        startCreating()
    }

    // MARK: - Methods

    func retry() {
        startCreating()
    }

    func cancel() {
        cancelTasks()
        Task {
            await coordinator.pop()
        }
    }

    func openContainer() {
        Task {
            let container = Container(
                id: UUID(),
                containerID: Data(),
                name: name,
                isAvailable: true,
                isOwned: true,
                files: files
            )
            await coordinator.finish()
            await coordinator.showContainerDetails(with: container)
        }
    }

    func goToList() {
        Task {
            await coordinator.finish()
        }
    }

    // MARK: - Private

    private func startCreating() {
        cancelTasks()

        phase = .loading
        status = .preparingFiles

        uiTask = Task { [weak self] in
            guard let self else { return }

            try? await Task.sleep(nanoseconds: 1_500_000_000)
            if Task.isCancelled { return }
            self.status = .encrypting

            try? await Task.sleep(nanoseconds: 1_500_000_000)
            if Task.isCancelled { return }
            self.status = .savingContainer
        }

        workTask = Task { [weak self] in
            guard let self else { return }

            let result = await self.mockCreateContainer()

            if Task.isCancelled { return }

            self.uiTask?.cancel()

            switch result {
            case .success:
                self.phase = .success
            case .failure:
                self.phase = .failure
            }
        }
    }

    private func cancelTasks() {
        uiTask?.cancel()
        workTask?.cancel()
        uiTask = nil
        workTask = nil
    }

    // MARK: - Mock

    private func mockCreateContainer() async -> Result<Void, Error> {
        let seconds = Double.random(in: 2.0...6.0)
        try? await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))

        let shouldFail = Bool.random() && Bool.random() // ~25%
        if shouldFail {
            return .failure(NSError(domain: "CreateContainer", code: 1))
        } else {
            return .success(())
        }
    }

    deinit {
        uiTask?.cancel()
        workTask?.cancel()
    }
}
