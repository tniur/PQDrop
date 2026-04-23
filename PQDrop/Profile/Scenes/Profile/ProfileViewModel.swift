//
//  ProfileViewModel.swift
//  PQDrop
//
//  Created by Pavel Bobkov on 19.04.2026.
//

import Combine
import CoreImage.CIFilterBuiltins
import Foundation
import PQUIComponents
import PQContainerKit
import UIKit

@MainActor
final class ProfileViewModel: ObservableObject {

    // MARK: - Properties

    @Published var showResetAlert = false
    @Published var qrPayload = ""
    @Published var qrCodeImage: UIImage?
    @Published var fingerprintBlocks: [FingerprintBlock] = []

    private let keyPairManager: KeyPairManager
    private let containerRepository: ContainerRepository
    private let contactRepository: ContactRepository
    private let historyRepository: HistoryRepository

    // MARK: - Initializer
    
    init(
        keyPairManager: KeyPairManager,
        containerRepository: ContainerRepository,
        contactRepository: ContactRepository,
        historyRepository: HistoryRepository
    ) {
        self.keyPairManager = keyPairManager
        self.containerRepository = containerRepository
        self.contactRepository = contactRepository
        self.historyRepository = historyRepository

        loadPublicKey()
    }

    // MARK: - Methods

    func copyCode() {
        guard !qrPayload.isEmpty else { return }
        UIPasteboard.general.string = qrPayload
        PQToast.show(with: String(localized: "profile.publicKey.copied"))
    }

    func resetAllData() {
        let containers = containerRepository.fetchAll()
        for container in containers {
            if let fileURL = container.fileURL {
                try? FileManager.default.removeItem(at: fileURL)
            }
            try? containerRepository.delete(by: container.id)
        }

        let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let containersDir = documentsDir.appendingPathComponent("Containers")
        try? FileManager.default.removeItem(at: containersDir)

        try? contactRepository.deleteAll()
        try? historyRepository.deleteOlderThan(days: 0)

        keyPairManager.deleteKeyPair()

        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.onboardingCompleted)

        NotificationCenter.default.post(name: .appResetRequested, object: nil)
    }

    // MARK: - Private

    private func loadPublicKey() {
        Task {
            guard let publicKey = try? keyPairManager.loadPublicKey() else { return }
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
