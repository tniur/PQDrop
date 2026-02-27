//
//  ProfileCoordinator.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 27.02.2026.
//

import SwiftUI
import SUICoordinator

@MainActor
final class ProfileCoordinator: Coordinator<ProfileRoute>, ProfileCoordinatorProtocol {

    override init() {
        super.init()
        Task { [weak self] in
            await self?.start()
        }
    }

    override func start() async {
        await startFlow(route: .profile(coordinator: self))
    }
}

