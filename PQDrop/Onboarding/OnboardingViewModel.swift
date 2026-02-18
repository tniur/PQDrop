//
//  OnboardingViewModel.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 17.02.2026.
//

import Combine

@MainActor
final class OnboardingViewModel: ObservableObject {
    
    @Published var steps: [OnboardingStep]
    @Published var index: Int = 0
    
    var isFirst: Bool {
        index == 0
    }
    var isLast: Bool {
        index >= steps.count - 1
    }
    
    private var onFinish: () -> Void = { }

    init(steps: [OnboardingStep]) {
        self.steps = steps
    }
    
    func topButtonAction() {
        if isLast {
            onFinish()
        }else {
            index += 1
        }
    }
    
    func bottomButtonAction() {
        if isFirst {
            onFinish()
        } else {
            index -= 1
        }
    }
}
