//
//  ContainersCoordinator.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 20.03.2026.
//

import SwiftUI
import SUICoordinator

@MainActor
final class ContainersCoordinator: Coordinator<ContainersRoute>, ContainersCoordinatorProtocol {

    override init() {
        super.init()
        Task { [weak self] in
            await self?.start()
        }
    }

    override func start() async {
        await startFlow(route: .containers(coordinator: self))
    }

    func finish() async {
        await restart()
    }
}
