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

    var addedFilesCount: Int {
        container.files.filter(\.isDraftAdded).count
    }

    var deletedFilesCount: Int {
        container.files.filter(\.isMarkedForDeletion).count
    }

    // MARK: - Private

    private let coordinator: ContainersCoordinatorProtocol

    // MARK: - Init

    init(coordinator: ContainersCoordinatorProtocol, container: Container) {
        self.coordinator = coordinator
        self.container = container
    }

    // MARK: - Actions

    func editName() {
        // TODO: - Navigate to edit name screen
    }

    func copyId() {
        UIPasteboard.general.string = container.id
    }

    func openFile(_ file: ContainerFileItem) {
        // TODO: Navigate to document/image viewer
    }

    func exportFile(_ file: ContainerFileItem) {
        shareItem = file.name
        showShareSheet = true
    }

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
        let importedFiles = urls.map { url in
            let resourceValues = try? url.resourceValues(forKeys: [.fileSizeKey, .nameKey])
            let fileSize = Int64(resourceValues?.fileSize ?? 0)
            let sizeText = ByteCountFormatter.string(fromByteCount: fileSize, countStyle: .file)

            return ContainerFileItem(
                id: UUID().uuidString,
                name: resourceValues?.name ?? url.lastPathComponent,
                sizeText: sizeText,
                isDraftAdded: true
            )
        }

        container.files.append(contentsOf: importedFiles)
    }

    func handlePickedPhotos(_ items: [PhotosPickerItem]) async {
        var pickedFiles: [ContainerFileItem] = []

        for (index, item) in items.enumerated() {
            guard let data = try? await item.loadTransferable(type: Data.self) else {
                continue
            }

            let ext = item.supportedContentTypes.first?.preferredFilenameExtension ?? "jpg"
            let sizeText = ByteCountFormatter.string(
                fromByteCount: Int64(data.count),
                countStyle: .file
            )

            pickedFiles.append(
                .init(
                    id: UUID().uuidString,
                    name: "Фото_\(index + 1).\(ext)",
                    sizeText: sizeText,
                    isDraftAdded: true
                )
            )
        }

        container.files.append(contentsOf: pickedFiles)
    }

    func toggleDeletion(for file: ContainerFileItem) {
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
        guard hasUnsavedChanges else { return }
        showSaveAlert = true
    }

    func save() {
        container.files.removeAll(where: \.isMarkedForDeletion)

        for index in container.files.indices {
            container.files[index].isDraftAdded = false
            container.files[index].isMarkedForDeletion = false
        }

        // TODO: launch re-encryption flow
    }
}
