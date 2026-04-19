//
//  ProfileCoordinator.swift
//  PQDrop
//
//  Created by Pavel Bobkov on 19.04.2026.
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

    func showQRCode() async {
        await navigate(toRoute: .qrCode(coordinator: self))
    }
}
