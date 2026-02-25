//
//  SplashViewModel.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 16.02.2026.
//

import Combine
import FactoryKit

@MainActor
final class SplashViewModel: ObservableObject {
    
    private var coordinator: AppCoordinator
    private var isShowingOnboarding: Bool = true
    
    init(coordinator: AppCoordinator) {
        self.coordinator = coordinator
    }
    
    func onAppear() {
        if isShowingOnboarding {
            Task {
                isShowingOnboarding = false
                await coordinator.showOnboarding()
            }
        } else {
            Task {
                await coordinator.showMainTabs()
            }
        }
    }
}
