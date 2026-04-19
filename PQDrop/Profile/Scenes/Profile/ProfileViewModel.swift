//
//  ProfileViewModel.swift
//  PQDrop
//
//  Created by Pavel Bobkov on 19.04.2026.
//

import Combine

@MainActor
final class ProfileViewModel: ObservableObject {

    // MARK: - Properties

    @Published var showResetAlert = false

    private let coordinator: ProfileCoordinatorProtocol
    
    // MARK: - Initializer

    init(coordinator: ProfileCoordinatorProtocol) {
        self.coordinator = coordinator
    }

    // MARK: - Methods

    func openQRCode() {
        Task {
            await coordinator.showQRCode()
        }
    }
}
