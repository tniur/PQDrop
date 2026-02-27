//
//  ProfileRoute.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 27.02.2026.
//

import SwiftUI
import SUICoordinator

enum ProfileRoute: RouteType {
    case profile(coordinator: ProfileCoordinatorProtocol)

    var presentationStyle: TransitionPresentationStyle { .push }

    var body: some View {
        switch self {
        case .profile(let coordinator):
            let viewModel = ProfileViewModel(coordinator: coordinator)
            let view = ProfileView(viewModel: viewModel)
            return AnyView(view)
        }
    }
}
