//
//  ProfileViewModel.swift
//  PQDrop
//
//  Created by Pavel Bobkov on 19.04.2026.
//

import Combine
import Foundation

@MainActor
final class ProfileViewModel: ObservableObject {

    // MARK: - Properties

    @Published var showResetAlert = false

    private let coordinator: ProfileCoordinatorProtocol
    private let keyPairManager: KeyPairManager
    private let containerRepository: ContainerRepository
    private let contactRepository: ContactRepository
    private let historyRepository: HistoryRepository

    // MARK: - Initializer
    
    init(
        coordinator: ProfileCoordinatorProtocol,
        keyPairManager: KeyPairManager,
        containerRepository: ContainerRepository = ContainerRepository(),
        contactRepository: ContactRepository = ContactRepository(),
        historyRepository: HistoryRepository = HistoryRepository()
    ) {
        self.coordinator = coordinator
        self.keyPairManager = keyPairManager
        self.containerRepository = containerRepository
        self.contactRepository = contactRepository
        self.historyRepository = historyRepository
    }

    // MARK: - Methods

    func openQRCode() {
        Task {
            await coordinator.showQRCode()
        }
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
}
