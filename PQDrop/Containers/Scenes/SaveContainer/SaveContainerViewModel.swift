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

    private var uiTask: Task<Void, Never>?
    private var workTask: Task<Void, Never>?

    private let coordinator: ContainersCoordinatorProtocol
    private let container: Container
    private let containerService: ContainerService
    private let historyRepository: HistoryRepository
    private let contactRepository: ContactRepository

    // MARK: - Initializer
    
    init(
        coordinator: ContainersCoordinatorProtocol,
        container: Container,
        containerService: ContainerService,
        historyRepository: HistoryRepository,
        contactRepository: ContactRepository
    ) {
        self.coordinator = coordinator
        self.container = container
        self.containerService = containerService
        self.historyRepository = historyRepository
        self.contactRepository = contactRepository
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
            case .failure:
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
            let recipients = try knownRecipientKeys(for: fileURL)

            try await Task.detached {
                try self.containerService.reencryptContainer(
                    name: self.container.name,
                    files: fileURLs,
                    originalContainerURL: fileURL,
                    destinationURL: tempURL,
                    recipients: recipients
                )
            }.value

            try FileManager.default.removeItem(at: fileURL)
            try FileManager.default.moveItem(at: tempURL, to: fileURL)

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

    private func knownRecipientKeys(for fileURL: URL) throws -> [XWing.PublicKey] {
        let info = try containerService.inspectContainer(at: fileURL)
        let recipientFingerprints = Set(info.recipientKeyIds)

        return contactRepository.fetchAll().compactMap { contact in
            guard let publicKey = try? XWing.PublicKey(rawRepresentation: contact.publicKeyRaw),
                  recipientFingerprints.contains(publicKey.fingerprint) else {
                return nil
            }

            return publicKey
        }
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
