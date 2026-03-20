//
//  QRScannerView.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 01.03.2026.
//

import SwiftUI

struct QRScannerView: UIViewRepresentable {

    // MARK: - Properties

    @Binding var isActive: Bool
    let onScan: (String) -> Void

    // MARK: - Methods

    func makeUIView(context: Context) -> QRCameraView {
        let view = QRCameraView()
        view.onScan = onScan
        return view
    }

    func updateUIView(_ uiView: QRCameraView, context: Context) {
        isActive ? uiView.restart() : uiView.stop()
    }

    static func dismantleUIView(_ uiView: QRCameraView, coordinator: ()) {
        uiView.stop()
    }
}
