//
//  ImportContainerViewModel.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 15.04.2026.
//

import Combine
import Foundation
import PQContainerKit

@MainActor
final class ImportContainerViewModel: ObservableObject {

    // MARK: - Enums

    enum Phase: Equatable {
        case loading
        case success
        case invalidFormat
        case accessDenied
    }

    // MARK: - Properties

    @Published var phase: Phase = .loading
    @Published var status: ImportContainerStatus = .checkingFormat

    private var uiTask: Task<Void, Never>?
    private var workTask: Task<Void, Never>?
    private var importedContainer: Container?

    private let coordinator: ContainersCoordinatorProtocol
    private let containerService: ContainerService
    private let containerRepository: ContainerRepository
    private let historyRepository: HistoryRepository
    private let keyPairManager: KeyPairManager
    private let fileURL: URL

    // MARK: - Initializer
    
    init(
        coordinator: ContainersCoordinatorProtocol,
        containerService: ContainerService,
        containerRepository: ContainerRepository,
        historyRepository: HistoryRepository,
        keyPairManager: KeyPairManager,
        fileURL: URL
    ) {
        self.coordinator = coordinator
        self.containerService = containerService
        self.containerRepository = containerRepository
        self.historyRepository = historyRepository
        self.keyPairManager = keyPairManager
        self.fileURL = fileURL
        startValidation()
    }

    // MARK: - Methods

    func openContainer() {
        guard let container = importedContainer else {
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

    func returnToList() {
        if phase == .accessDenied {
            Task {
                await coordinator.finish()
            }
        } else {
            Task {
                await coordinator.pop()
            }
        }
    }

    // MARK: - Private

    private func startValidation() {
        cancelTasks()

        phase = .loading
        status = .checkingFormat
        importedContainer = nil

        uiTask = Task { [weak self] in
            guard let self else { return }

            try? await Task.sleep(nanoseconds: 800_000_000)
            if Task.isCancelled { return }
            self.status = .checkingFingerprint

            try? await Task.sleep(nanoseconds: 800_000_000)
            if Task.isCancelled { return }
            self.status = .checkingAccess
        }

        workTask = Task { [weak self] in
            guard let self else { return }

            let result = await self.performValidation()

            if Task.isCancelled { return }

            self.uiTask?.cancel()

            switch result {
            case .success(let container):
                self.importedContainer = container
                self.phase = .success
            case .invalidFormat:
                self.phase = .invalidFormat
            case .accessDenied(let container):
                self.importedContainer = container
                self.phase = .accessDenied
            }
        }
    }

    private func performValidation() async -> ValidationResult {
        do {
            let hasAccess = fileURL.startAccessingSecurityScopedResource()
            defer {
                if hasAccess {
                    fileURL.stopAccessingSecurityScopedResource()
                }
            }

            let info = try containerService.inspectContainer(at: fileURL)

            guard let myPublicKey = try keyPairManager.loadOrMigratePublicKey() else {
                return .invalidFormat
            }

            let containersDir = try Self.containersDirectory()
            let fileName = fileURL.lastPathComponent
            let destinationURL = containersDir.appendingPathComponent(UUID().uuidString + "_" + fileName)
            try FileManager.default.copyItem(at: fileURL, to: destinationURL)

            let containerName = fileURL.deletingPathExtension().lastPathComponent
            let isAvailable = info.containsRecipient(myPublicKey)

            let container = try containerRepository.create(
                name: containerName,
                containerID: info.header.containerID.rawValue,
                fileURL: destinationURL,
                isOwned: false,
                isAvailable: isAvailable
            )

            try? historyRepository.append(
                type: .imported,
                containerID: info.header.containerID.rawValue,
                containerName: containerName
            )

            if isAvailable {
                return .success(container)
            } else {
                return .accessDenied(container)
            }
        } catch {
            return .invalidFormat
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

    deinit {
        uiTask?.cancel()
        workTask?.cancel()
    }
}

private enum ValidationResult {
    case success(Container)
    case invalidFormat
    case accessDenied(Container)
}
