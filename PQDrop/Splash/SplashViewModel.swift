//
//  SplashViewModel.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 16.02.2026.
//

import Combine
import FactoryKit
import Foundation

@MainActor
final class SplashViewModel: ObservableObject {
    
    // MARK: - Properties

    private let coordinator: AppCoordinatorProtocol
    private var isShowingOnboarding: Bool = true
    
    // MARK: - Initializer
    
    init(coordinator: AppCoordinatorProtocol) {
        self.coordinator = coordinator
    }
    
    // MARK: - Methods

    func onAppear() {
        let onboardingCompleted = UserDefaults.standard.bool(forKey: UserDefaultsKeys.onboardingCompleted)
        
        Task {
            if onboardingCompleted {
                await coordinator.showMainTabs()
            } else {
                await coordinator.showOnboarding()
            }
        }
    }
}
