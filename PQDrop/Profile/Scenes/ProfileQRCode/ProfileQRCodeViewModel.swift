//
//  ProfileQRCodeViewModel.swift
//  PQDrop
//
//  Created by Pavel Bobkov on 19.04.2026.
//

import SwiftUI
import UIKit
import Combine
import PQContainerKit
import CoreImage.CIFilterBuiltins

@MainActor
final class ProfileQRCodeViewModel: ObservableObject {

    // MARK: - Properties

    @Published var qrPayload = ""
    @Published var qrCodeImage: UIImage?
    @Published var fingerprintBlocks: [FingerprintBlock] = []

    private let coordinator: ProfileCoordinatorProtocol
    private let keyPairManager: KeyPairManager

    // MARK: - Initializer

    init(coordinator: ProfileCoordinatorProtocol, keyPairManager: KeyPairManager) {
        self.coordinator = coordinator
        self.keyPairManager = keyPairManager

        loadPublicKey()
    }

    // MARK: - Methods

    func copyCode() {
        UIPasteboard.general.string = qrPayload
    }

    // MARK: - Private

    private func loadPublicKey() {
        Task {
            guard let publicKey = try? keyPairManager.loadPublicKeyRequiringAuthentication(
                reason: "Показать QR профиля"
            ) else { return }
            let base64 = publicKey.base64

            qrPayload = base64
            fingerprintBlocks = publicKey.fingerprint.hexStringGrouped
                .components(separatedBy: " ")
                .enumerated()
                .map { FingerprintBlock(id: $0.offset, text: $0.element) }

            let image = await Task.detached(priority: .userInitiated) {
                Self.makeQRCodeImage(from: base64)
            }.value

            qrCodeImage = image
        }
    }

    nonisolated private static func makeQRCodeImage(from string: String) -> UIImage? {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)
        filter.correctionLevel = "L"

        guard let outputImage = filter.outputImage else { return nil }

        let scale = max(1, 600 / outputImage.extent.width)
        let transformedImage = outputImage.transformed(
            by: CGAffineTransform(scaleX: scale, y: scale)
        )

        guard let cgImage = context.createCGImage(transformedImage, from: transformedImage.extent) else {
            return nil
        }

        return UIImage(cgImage: cgImage)
    }
}
