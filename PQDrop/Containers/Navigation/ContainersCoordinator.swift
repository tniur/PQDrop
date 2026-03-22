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

    func showContainerDetails(with container: Container) async {
        await navigate(toRoute: .containerDetails(coordinator: self, container: container))
    }

    func showRecipientsSheet(recipients: [Recipient]) async {
        await navigate(toRoute: .recipientsSheet(recipients: recipients))
    }
}
