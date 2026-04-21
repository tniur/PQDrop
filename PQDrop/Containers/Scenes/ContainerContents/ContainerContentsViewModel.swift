//
//  ContainerContentsViewModel.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 07.04.2026.
//

import SwiftUI
import Combine
import UIKit
import PhotosUI
import UniformTypeIdentifiers
import QuickLook

@MainActor
final class ContainerContentsViewModel: ObservableObject {

    // MARK: - Published

    @Published var container: Container
    @Published var showShareSheet = false
    @Published var shareItem: Any?
    @Published var showSaveAlert = false

    @Published var showAddFilesSheet = false
    @Published var showFilesImporter = false
    @Published var showPhotosPicker = false

    // MARK: - Computed

    var files: [ContainerFileItem] {
        container.files
    }

    var hasUnsavedChanges: Bool {
        container.files.contains(where: { $0.isDraftAdded || $0.isMarkedForDeletion })
    }

    var isEmptyState: Bool {
        container.files.isEmpty
    }

    var canEditContents: Bool {
        container.isOwned && container.isAvailable
    }

    var addedFilesCount: Int {
        container.files.filter(\.isDraftAdded).count
    }

    var deletedFilesCount: Int {
        container.files.filter(\.isMarkedForDeletion).count
    }

    // MARK: - Private

    private let coordinator: ContainersCoordinatorProtocol
    private var decryptedDir: URL?
    private var backgroundObserver: NSObjectProtocol?

    // MARK: - Init

    init(
        coordinator: ContainersCoordinatorProtocol,
        container: Container,
        decryptedDir: URL
    ) {
        self.coordinator = coordinator
        self.container = container
        self.decryptedDir = decryptedDir
        observeBackground()
    }

    // MARK: - Actions

    func editName() {
        Task {
            await coordinator.showEditContainerName(mode: .edit(container: container))
        }
    }

    func copyId() {
        UIPasteboard.general.string = container.id.uuidString
    }

    func openFile(_ file: ContainerFileItem) {
        Task {
            await coordinator.showFileViewer(with: file)
        }
    }

    func exportFile(_ file: ContainerFileItem) {
        guard let url = file.localURL else { return }
        shareItem = url
        showShareSheet = true
    }

    func presentAddFilesSheet() {
        guard canEditContents else { return }
        showAddFilesSheet = true
    }

    func openFilesImporter() {
        guard canEditContents else { return }
        showAddFilesSheet = false
        showFilesImporter = true
    }

    func openPhotosPicker() {
        guard canEditContents else { return }
        showAddFilesSheet = false
        showPhotosPicker = true
    }

    func handleImportedFiles(urls: [URL]) {
        guard canEditContents else { return }

        let importedFiles: [ContainerFileItem] = urls.compactMap { sourceURL in
            let hasAccess = sourceURL.startAccessingSecurityScopedResource()
            defer {
                if hasAccess {
                    sourceURL.stopAccessingSecurityScopedResource()
                }
            }

            let resourceValues = try? sourceURL.resourceValues(forKeys: [.fileSizeKey, .nameKey])
            let fileName = resourceValues?.name ?? sourceURL.lastPathComponent
            let ext = sourceURL.pathExtension
            let destinationURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension(ext)

            do {
                if FileManager.default.fileExists(atPath: destinationURL.path) {
                    try FileManager.default.removeItem(at: destinationURL)
                }

                try FileManager.default.copyItem(at: sourceURL, to: destinationURL)

                let copiedValues = try? destinationURL.resourceValues(forKeys: [.fileSizeKey])
                let fileSize = Int64(copiedValues?.fileSize ?? 0)
                let sizeText = ByteCountFormatter.string(fromByteCount: fileSize, countStyle: .file)

                return ContainerFileItem(
                    id: UUID().uuidString,
                    name: fileName,
                    sizeText: sizeText,
                    localURL: destinationURL,
                    isDraftAdded: true
                )
            } catch {
                return nil
            }
        }

        container.files.append(contentsOf: importedFiles)
    }

    func handlePickedPhotos(_ items: [PhotosPickerItem]) async {
        guard canEditContents else { return }

        var pickedFiles: [ContainerFileItem] = []

        for (index, item) in items.enumerated() {
            guard let data = try? await item.loadTransferable(type: Data.self) else {
                continue
            }

            let ext = item.supportedContentTypes.first?.preferredFilenameExtension ?? "jpg"
            let fileName = "Фото_\(index + 1).\(ext)"
            let destinationURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension(ext)

            do {
                try data.write(to: destinationURL, options: .atomic)

                let sizeText = ByteCountFormatter.string(
                    fromByteCount: Int64(data.count),
                    countStyle: .file
                )

                pickedFiles.append(
                    ContainerFileItem(
                        id: UUID().uuidString,
                        name: fileName,
                        sizeText: sizeText,
                        localURL: destinationURL,
                        isDraftAdded: true
                    )
                )
            } catch {}
        }

        container.files.append(contentsOf: pickedFiles)
    }

    func toggleDeletion(for file: ContainerFileItem) {
        guard canEditContents else { return }

        guard let index = container.files.firstIndex(where: { $0.id == file.id }) else {
            return
        }

        if container.files[index].isDraftAdded {
            container.files.remove(at: index)
            return
        }

        container.files[index].isMarkedForDeletion.toggle()
    }

    func confirmSave() {
        guard canEditContents, hasUnsavedChanges else { return }
        showSaveAlert = true
    }

    func save() {
        guard canEditContents else { return }

        container.files.removeAll(where: \.isMarkedForDeletion)

        for index in container.files.indices {
            container.files[index].isDraftAdded = false
            container.files[index].isMarkedForDeletion = false
        }

        Task {
            await coordinator.showSaveContainer(with: container)
        }
    }

    func cleanupDecryptedFiles() {
        guard let dir = decryptedDir else { return }
        try? FileManager.default.removeItem(at: dir)
        decryptedDir = nil
        container.files = []
    }

    private func observeBackground() {
        backgroundObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.cleanupDecryptedFiles()
            }
        }
    }

    deinit {
        if let backgroundObserver {
            NotificationCenter.default.removeObserver(backgroundObserver)
        }

        if let decryptedDir {
            try? FileManager.default.removeItem(at: decryptedDir)
        }
    }
}
