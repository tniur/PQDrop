//
//  OnboardingCoordinator.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 25.02.2026.
//

import SwiftUI
import SUICoordinator

@MainActor
final class OnboardingCoordinator: Coordinator<OnboardingRoute>, OnboardingCoordinatorProtocol {

    override init() {
        super.init()
        Task { [weak self] in
            await self?.start()
        }
    }

    override func start() async {
        await startFlow(route: .onboarding(coordinator: self))
    }
    
    func showCreateKeys() async {
        await navigate(toRoute: .createKeys(coordinator: self))
    }
    
    func restartSplash() async {
        let coordinator = AppCoordinator()
        await navigate(to: coordinator, presentationStyle: .fullScreenCover)
    }
}

