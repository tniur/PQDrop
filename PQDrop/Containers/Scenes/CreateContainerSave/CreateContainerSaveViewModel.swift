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
    private var createdContainer: Container?

    private let coordinator: ContainersCoordinatorProtocol
    private let containerService: ContainerService
    private let containerRepository: ContainerRepository
    private let historyRepository: HistoryRepository
    private let name: String
    private let files: [ContainerFileItem]
    private let workspaceRoot: URL

    init(
        coordinator: ContainersCoordinatorProtocol,
        containerService: ContainerService,
        containerRepository: ContainerRepository,
        historyRepository: HistoryRepository,
        name: String,
        files: [ContainerFileItem],
        workspaceRoot: URL
    ) {
        self.coordinator = coordinator
        self.containerService = containerService
        self.containerRepository = containerRepository
        self.historyRepository = historyRepository
        self.name = name
        self.files = files
        self.workspaceRoot = workspaceRoot
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
        guard let container = createdContainer else {
            return
        }

        Task {
            await coordinator.showContainerDetailsFromRoot(with: container)
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
        createdContainer = nil

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

            let result = await self.performCreate()

            if Task.isCancelled { return }

            self.uiTask?.cancel()

            switch result {
            case .success(let container):
                self.cleanupWorkspace()
                self.createdContainer = container
                self.phase = .success
            case .failure:
                self.phase = .failure
            }
        }
    }

    private func performCreate() async -> Result<Container, Error> {
        do {
            let fileURLs = files.compactMap(\.localURL)
            let containersDir = try Self.containersDirectory()

            let result = try await Task.detached {
                try self.containerService.createContainer(
                    name: self.name,
                    files: fileURLs,
                    recipients: [],
                    destinationDir: containersDir
                )
            }.value

            let container = try containerRepository.create(
                name: name,
                containerID: result.containerID,
                fileURL: result.fileURL,
                isOwned: true,
                isAvailable: true
            )

            try? historyRepository.append(
                type: .export,
                containerID: result.containerID,
                containerName: name
            )

            return .success(container)
        } catch {
            return .failure(error)
        }
    }

    private static func containersDirectory() throws -> URL {
        let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let containersDir = documentsDir.appendingPathComponent("Containers")
        try FileManager.default.createDirectory(at: containersDir, withIntermediateDirectories: true)

        return containersDir
    }

    private func cancelTasks() {
        uiTask?.cancel()
        workTask?.cancel()
        uiTask = nil
        workTask = nil
    }

    private func cleanupWorkspace() {
        try? FileManager.default.removeItem(at: workspaceRoot)
    }

    deinit {
        uiTask?.cancel()
        workTask?.cancel()
    }
}
