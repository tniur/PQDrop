//
//  QRCameraView.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 01.03.2026.
//

import UIKit
import AVFoundation

final class QRCameraView: UIView {

    // MARK: - Properties

    var onScan: ((String) -> Void)?

    private let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "pqdrop.camera.session")
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var didScan = false

    // MARK: - Lifecycle

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        setupSession()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer?.frame = bounds
    }

    // MARK: - Setup

    private func setupSession() {
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else { return }

        session.addInput(input)

        let output = AVCaptureMetadataOutput()
        guard session.canAddOutput(output) else { return }
        session.addOutput(output)
        output.setMetadataObjectsDelegate(self, queue: .main)
        output.metadataObjectTypes = [.qr]

        let preview = AVCaptureVideoPreviewLayer(session: session)
        preview.videoGravity = .resizeAspectFill
        preview.frame = bounds
        layer.addSublayer(preview)
        previewLayer = preview

        sessionQueue.async { self.session.startRunning() }
    }

    // MARK: - Controls

    func stop() {
        sessionQueue.async { self.session.stopRunning() }
    }

    func restart() {
        didScan = false
        sessionQueue.asyncAfter(deadline: .now() + 0.5) {
            guard !self.session.isRunning else { return }
            self.session.startRunning()
        }
    }
}

// MARK: - AVCaptureMetadataOutputObjectsDelegate

extension QRCameraView: AVCaptureMetadataOutputObjectsDelegate {

    func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        guard
            let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
            let value = object.stringValue,
            !didScan
        else { return }

        didScan = true
        sessionQueue.async { self.session.stopRunning() }
        onScan?(value)
    }
}
