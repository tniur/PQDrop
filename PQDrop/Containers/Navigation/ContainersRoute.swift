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
    case containerDetails(coordinator: ContainersCoordinatorProtocol, container: Container)
    case recipientsSheet(recipients: [Recipient])
    case accessControl(coordinator: ContainersCoordinatorProtocol, container: Container)

    var presentationStyle: TransitionPresentationStyle {
        switch self {
        case .containers, .containerDetails, .accessControl:
            .push
        case .recipientsSheet:
            .sheet
        }
    }

    var body: some View {
        switch self {
        case .containers(let coordinator):
            let viewModel = ContainersViewModel(coordinator: coordinator)
            let view = ContainersView(viewModel: viewModel)
            return AnyView(view)

        case .containerDetails(let coordinator, let container):
            let viewModel = ContainerDetailsViewModel(coordinator: coordinator, container: container)
            let view = ContainerDetailsView(viewModel: viewModel)
            return AnyView(view)

        case .recipientsSheet(let recipients):
            let view = RecipientsSheetView(recipients: recipients)
            return AnyView(view)

        case .accessControl(let coordinator, let container):
            let viewModel = AccessControlViewModel(coordinator: coordinator, container: container)
            let view = AccessControlView(viewModel: viewModel)
            return AnyView(view)
        }
    }
}
