//
//  AppCoordinator.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 19.02.2026.
//

import SwiftUI
import SUICoordinator

@MainActor
final class AppCoordinator: Coordinator<AppRoute>, AppCoordinatorProtocol {

    override init() {
        super.init()
        Task { [weak self] in
            await self?.start()
        }
    }

    override func start() async {
        await startFlow(route: .splash(coordinator: self))
    }
    
    func showOnboarding() async {
        let coordinator = OnboardingCoordinator()
        await navigate(to: coordinator, presentationStyle: .fullScreenCover)
    }
    
    func showMainTabs() async {
        let coordinator = MainTabCoordinator()
        await navigate(to: coordinator, presentationStyle: .fullScreenCover)
    }
    
    func restartSplash() async {
        await router.popToRoot()
    }
}

