//
//  SaveContainerViewModel.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 12.04.2026.
//

import Combine
import Foundation

@MainActor
final class SaveContainerViewModel: ObservableObject {

    // MARK: - Enums

    enum Phase: Equatable {
        case loading
        case success
        case failure
    }

    // MARK: - Properties

    @Published var phase: Phase = .loading
    @Published var status: SaveContainerStatus = .preparingFiles

    private var uiTask: Task<Void, Never>?
    private var workTask: Task<Void, Never>?

    private let coordinator: ContainersCoordinatorProtocol
    private let container: Container

    // MARK: - Initializer

    init(coordinator: ContainersCoordinatorProtocol, container: Container) {
        self.coordinator = coordinator
        self.container = container
        startSaving()
    }

    // MARK: - Methods

    func retry() {
        startSaving()
    }

    func cancel() {
        cancelTasks()
        Task {
            await coordinator.pop()
        }
    }

    func goBack() {
        Task {
            await coordinator.pop()
        }
    }

    // MARK: - Private

    private func startSaving() {
        cancelTasks()

        phase = .loading
        status = .preparingFiles

        uiTask = Task { [weak self] in
            guard let self else { return }

            // Меняем статус по таймеру, пока идёт реальная работа
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            if Task.isCancelled { return }
            self.status = .updatingContainer

            try? await Task.sleep(nanoseconds: 1_500_000_000)
            if Task.isCancelled { return }
            self.status = .reEncrypting
        }

        workTask = Task { [weak self] in
            guard let self else { return }

            let result = await self.mockSaveContainer()

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

    private func mockSaveContainer() async -> Result<Void, Error> {
        let seconds = Double.random(in: 2.0...6.0)
        try? await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))

        let shouldFail = Bool.random() && Bool.random() // ~25%
        if shouldFail {
            return .failure(NSError(domain: "SaveContainer", code: 1))
        } else {
            return .success(())
        }
    }

    deinit {
        uiTask?.cancel()
        workTask?.cancel()
    }
}
