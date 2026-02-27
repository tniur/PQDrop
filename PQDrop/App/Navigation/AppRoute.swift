//
//  AppRoute.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 19.02.2026.
//

import SwiftUI
import SUICoordinator

enum AppRoute: RouteType {
    case splash(coordinator: AppCoordinatorProtocol)

    var presentationStyle: TransitionPresentationStyle { .push }

    var body: some View {
        switch self {
        case .splash(let coordinator):
            let viewModel = SplashViewModel(coordinator: coordinator)
            let view = SplashView(viewModel: viewModel)
            return AnyView(view)
        }
    }
}
