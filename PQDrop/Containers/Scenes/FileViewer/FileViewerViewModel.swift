//
//  FileViewerViewModel.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 09.04.2026.
//

import Combine
import Foundation
import QuickLook

@MainActor
final class FileViewerViewModel: ObservableObject {
    
    // MARK: - Properties

    @Published var showShareSheet = false

    let item: ContainerFileItem

    var canPreview: Bool {
        guard let url = item.localURL else { return false }
        return QLPreviewController.canPreview(url as NSURL)
    }

    // MARK: - Init

    init(item: ContainerFileItem) {
        self.item = item
    }

    // MARK: - Methods

    func exportFile() {
        showShareSheet = true
    }
}
