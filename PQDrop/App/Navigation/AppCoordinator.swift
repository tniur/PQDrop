//
//  AppCoordinator.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 19.02.2026.
//

import SwiftUI
import SUICoordinator

@MainActor
final class AppCoordinator: Coordinator<AppRoute> {

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
        await navigate(toRoute: .onboarding(coordinator: self))
    }
    
    func showMainTabs() async {
        await navigate(toRoute: .mainTabs(coordinator: self))
    }
    
    func restartSplash() async {
        await router.popToRoot()
    }
}

