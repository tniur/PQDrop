//
//  ProfileViewModel.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 27.02.2026.
//

import Combine

final class ProfileViewModel: ObservableObject {
    
    private let coordinator: ProfileCoordinatorProtocol
    
    init(coordinator: ProfileCoordinatorProtocol) {
        self.coordinator = coordinator
    }
}
