//
//  OnboardingRoute.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 25.02.2026.
//

import SwiftUI
import SUICoordinator

enum OnboardingRoute: RouteType {
    case onboarding(coordinator: OnboardingCoordinatorProtocol)
    case createKeys(coordinator: OnboardingCoordinatorProtocol)

    var presentationStyle: TransitionPresentationStyle { .push }

    var body: some View {
        switch self {
        case .onboarding(let coordinator):
            let viewModel = OnboardingViewModel(coordinator: coordinator)
            let view = OnboardingView(viewModel: viewModel)
            return AnyView(view)
            
        case .createKeys(let coordinator):
            let viewModel = CreateKeysViewModel(coordinator: coordinator)
            let view = CreateKeysView(viewModel: viewModel)
            return AnyView(view)
        }
    }
}
