//
//  OnboardingViewModel.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 17.02.2026.
//

import Combine
import FactoryKit

@MainActor
final class OnboardingViewModel: ObservableObject {
    
    @Published var steps: [OnboardingStep] = OnboardingStep.mock
    @Published var index: Int = 0
    
    var isFirst: Bool {
        index == 0
    }
    var isLast: Bool {
        index >= steps.count - 1
    }
        
    private var coordinator: OnboardingCoordinatorProtocol

    init(coordinator: OnboardingCoordinatorProtocol) {
        self.coordinator = coordinator
    }
    
    func topButtonAction() {
        if isLast {
            createKeys()
        } else {
            index += 1
        }
    }
    
    func bottomButtonAction() {
        if isFirst {
            createKeys()
        } else {
            index -= 1
        }
    }
    
    private func createKeys() {
        Task {
            await coordinator.showCreateKeys()
        }
    }
}
