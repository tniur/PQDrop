//
//  CreateContainerFilesViewModel.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 13.04.2026.
//

import SwiftUI
import Combine
import PhotosUI
import UniformTypeIdentifiers

@MainActor
final class CreateContainerFilesViewModel: ObservableObject {

    // MARK: - Published

    @Published var files: [ContainerFileItem] = []
    @Published var showAddFilesSheet = false
    @Published var showFilesImporter = false
    @Published var showPhotosPicker = false

    // MARK: - Computed

    var hasFiles: Bool {
        !files.isEmpty
    }

    // MARK: - Private

    let name: String
    private let coordinator: ContainersCoordinatorProtocol

    // MARK: - Init

    init(coordinator: ContainersCoordinatorProtocol, name: String) {
        self.coordinator = coordinator
        self.name = name
    }

    // MARK: - Actions

    func presentAddFilesSheet() {
        showAddFilesSheet = true
    }

    func openFilesImporter() {
        showAddFilesSheet = false
        showFilesImporter = true
    }

    func openPhotosPicker() {
        showAddFilesSheet = false
        showPhotosPicker = true
    }

    func handleImportedFiles(urls: [URL]) {
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
                    localURL: destinationURL
                )
            } catch {
                return nil
            }
        }

        withAnimation(.easeInOut(duration: 0.22)) {
            files.append(contentsOf: importedFiles)
        }
    }

    func handlePickedPhotos(_ items: [PhotosPickerItem]) async {
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
                        localURL: destinationURL
                    )
                )
            } catch {}
        }

        withAnimation(.easeInOut(duration: 0.22)) {
            files.append(contentsOf: pickedFiles)
        }
    }

    func openFile(_ file: ContainerFileItem) {
        Task {
            await coordinator.showFileViewer(with: file)
        }
    }

    func removeFile(_ file: ContainerFileItem) {
        withAnimation(.easeInOut(duration: 0.22)) {
            files.removeAll { $0.id == file.id }
        }
    }

    func create() {
        Task {
            await coordinator.showCreateContainerSave(name: name, files: files)
        }
    }
}
