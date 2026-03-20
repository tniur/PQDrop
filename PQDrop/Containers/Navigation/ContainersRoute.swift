//
//  ContainersRoute.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 20.03.2026.
//

import SwiftUI
import SUICoordinator

enum ContainersRoute: RouteType {
    case containers(coordinator: ContainersCoordinatorProtocol)

    var presentationStyle: TransitionPresentationStyle {
        switch self {
        case .containers:
            .push
        }
    }

    var body: some View {
        switch self {
        case .containers(let coordinator):
            let viewModel = ContainersViewModel(coordinator: coordinator)
            let view = ContainersView(viewModel: viewModel)
            return AnyView(view)
        }
    }
}
