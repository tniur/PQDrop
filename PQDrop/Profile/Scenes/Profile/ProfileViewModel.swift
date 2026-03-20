//
//  ProfileViewModel.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 27.02.2026.
//

import Combine

final class ProfileViewModel: ObservableObject {
    
    // MARK: - Properties

    private let coordinator: ProfileCoordinatorProtocol
    
    // MARK: - Initializer

    init(coordinator: ProfileCoordinatorProtocol) {
        self.coordinator = coordinator
    }
}
