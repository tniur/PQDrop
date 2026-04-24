//
//  ActivityViewControllerRepresentable.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 22.03.2026.
//

import SwiftUI

struct ActivityViewControllerRepresentable: UIViewControllerRepresentable {

    // MARK: - Properties

    private let activityItems: [Any]
    private let onComplete: (@MainActor () -> Void)?

    // MARK: - Init

    init(
        activityItems: [Any],
        onComplete: (@MainActor () -> Void)? = nil
    ) {
        self.activityItems = activityItems
        self.onComplete = onComplete
    }

    // MARK: - UIViewControllerRepresentable

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        controller.completionWithItemsHandler = { _, _, _, _ in
            Task { @MainActor in
                onComplete?()
            }
        }
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
