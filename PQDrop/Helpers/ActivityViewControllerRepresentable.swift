//
//  ActivityViewControllerRepresentable.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 22.03.2026.
//

import SwiftUI

struct ActivityViewControllerRepresentable: UIViewControllerRepresentable {

    // MARK: - Properties

    let activityItems: [Any]

    // MARK: - UIViewControllerRepresentable

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
