//
//  ImportContainerViewModel.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 15.04.2026.
//

import Combine
import Foundation

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
    private let fileURL: URL

    // MARK: - Initializer

    init(coordinator: ContainersCoordinatorProtocol, fileURL: URL) {
        self.coordinator = coordinator
        self.fileURL = fileURL
        startValidation()
    }

    // MARK: - Methods

    func openContainer() {
        let container = persistImportedContainer(isAvailable: true)
        Task {
            await coordinator.finish()
            await coordinator.showContainerDetails(with: container)
        }
    }

    func goToList() {
        _ = persistImportedContainer(isAvailable: true)
        Task {
            await coordinator.finish()
        }
    }

    func returnToList() {
        if phase == .accessDenied {
            _ = persistImportedContainer(isAvailable: false)
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

            try? await Task.sleep(nanoseconds: 1_100_000_000)
            if Task.isCancelled { return }
            self.status = .checkingFingerprint

            try? await Task.sleep(nanoseconds: 1_100_000_000)
            if Task.isCancelled { return }
            self.status = .checkingAccess
        }

        workTask = Task { [weak self] in
            guard let self else { return }

            try? await Task.sleep(nanoseconds: 3_300_000_000)
            if Task.isCancelled { return }

            self.uiTask?.cancel()
            self.phase = self.mockValidationResult()
        }
    }

    private func persistImportedContainer(isAvailable: Bool) -> Container {
        if let importedContainer {
            return importedContainer
        }

        let container = ContainersMockStore.addImportedContainer(
            from: fileURL,
            isAvailable: isAvailable
        )
        importedContainer = container
        return container
    }

    private func mockValidationResult() -> Phase {
        let name = fileURL.deletingPathExtension().lastPathComponent.lowercased()
        let fileExtension = fileURL.pathExtension.lowercased()

        if name.contains("locked") ||
            name.contains("denied") ||
            name.contains("blocked") ||
            name.contains("noaccess") ||
            name.contains("недоступ") ||
            name.contains("заблок") {
            return .accessDenied
        }

        if name.contains("invalid") ||
            name.contains("wrong") ||
            name.contains("error") ||
            name.contains("ошибка") ||
            ["png", "jpg", "jpeg", "pdf", "txt", "rtf"].contains(fileExtension) {
            return .invalidFormat
        }

        return .success
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
