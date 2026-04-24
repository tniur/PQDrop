//
//  SaveContainerViewModel.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 12.04.2026.
//

import Combine
import Foundation
import PQContainerKit

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
    @Published var errorMessage = ""

    private var uiTask: Task<Void, Never>?
    private var workTask: Task<Void, Never>?

    private let coordinator: ContainersCoordinatorProtocol
    private let container: Container
    private let containerService: ContainerService
    private let historyRepository: HistoryRepository
    private let contactRepository: ContactRepository
    private let containerRepository: ContainerRepository

    // MARK: - Initializer
    
    init(
        coordinator: ContainersCoordinatorProtocol,
        container: Container,
        containerService: ContainerService,
        historyRepository: HistoryRepository,
        contactRepository: ContactRepository,
        containerRepository: ContainerRepository
    ) {
        self.coordinator = coordinator
        self.container = container
        self.containerService = containerService
        self.historyRepository = historyRepository
        self.contactRepository = contactRepository
        self.containerRepository = containerRepository
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
        errorMessage = ""

        uiTask = Task { [weak self] in
            guard let self else { return }

            try? await Task.sleep(nanoseconds: 1_500_000_000)
            if Task.isCancelled { return }
            self.status = .updatingContainer

            try? await Task.sleep(nanoseconds: 1_500_000_000)
            if Task.isCancelled { return }
            self.status = .reEncrypting
        }

        workTask = Task { [weak self] in
            guard let self else { return }

            let result = await self.saveContainer()

            if Task.isCancelled { return }

            self.uiTask?.cancel()

            switch result {
            case .success:
                self.phase = .success
            case .failure(let error):
                self.errorMessage = self.saveErrorMessage(error)
                self.phase = .failure
            }
        }
    }

    private func saveContainer() async -> Result<Void, Error> {
        guard let fileURL = container.fileURL else {
            return .failure(ContainerServiceError.noKeyPair)
        }

        let fileURLs = container.files.compactMap(\.localURL)
        guard !fileURLs.isEmpty else {
            return .failure(ContainerServiceError.noKeyPair)
        }

        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("pqck")

        do {
            let resolvedRecipients = try containerService.resolveCurrentNonOwnerRecipients(
                at: fileURL,
                storedRecipientPublicKeysRaw: container.recipientPublicKeysRaw,
                contacts: contactRepository.fetchAll()
            )

            try await Task.detached {
                try self.containerService.reencryptContainer(
                    name: self.container.name,
                    files: fileURLs,
                    originalContainerURL: fileURL,
                    destinationURL: tempURL,
                    recipients: resolvedRecipients.publicKeys
                )
            }.value

            try FileManager.default.removeItem(at: fileURL)
            try FileManager.default.moveItem(at: tempURL, to: fileURL)
            try? containerRepository.updateRecipientPublicKeys(
                resolvedRecipients.rawPublicKeys,
                for: container.id
            )

            try? historyRepository.append(
                type: .export,
                containerID: container.containerID,
                containerName: container.name
            )

            return .success(())
        } catch {
            try? FileManager.default.removeItem(at: tempURL)
            return .failure(error)
        }
    }

    private func cancelTasks() {
        uiTask?.cancel()
        workTask?.cancel()
        uiTask = nil
        workTask = nil
    }

    private func saveErrorMessage(_ error: Error) -> String {
        if let serviceError = error as? ContainerServiceError {
            switch serviceError {
            case .noKeyPair:
                return String(localized: "containers.access.error.no.key.pair")
            case .recipientKeysUnavailable:
                return String(localized: "containers.access.error.recipient.keys.unavailable")
            }
        }

        if let containerError = error as? ContainerError {
            switch containerError {
            case .accessDenied:
                return String(localized: "containers.access.error.access.denied")
            case .invalidFormat, .unsupportedVersion:
                return String(localized: "containers.access.error.invalid.format")
            case .limitsExceeded:
                return String(localized: "containers.access.error.limits.exceeded")
            case .ioError:
                return String(localized: "containers.access.error.io")
            case .cannotOpen:
                return String(localized: "containers.access.error.cannot.open")
            }
        }

        return String(localized: "shared.try.again")
    }

    deinit {
        uiTask?.cancel()
        workTask?.cancel()
    }
}
