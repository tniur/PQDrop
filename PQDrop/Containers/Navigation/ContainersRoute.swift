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
    case containersContents(coordinator: ContainersCoordinatorProtocol, container: Container)
    case fileViewer(item: ContainerFileItem)
    case saveContainer(coordinator: ContainersCoordinatorProtocol, container: Container)
    case editContainerName(coordinator: ContainersCoordinatorProtocol, mode: EditContainerNameViewModel.Mode)
    case createContainerFiles(coordinator: ContainersCoordinatorProtocol, name: String)
    case createContainerSave(coordinator: ContainersCoordinatorProtocol, name: String, files: [ContainerFileItem])

    var presentationStyle: TransitionPresentationStyle {
        switch self {
        case .containers, .containerDetails, .accessControl, .containersContents, .fileViewer, .saveContainer,
             .editContainerName, .createContainerFiles, .createContainerSave:
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

        case .containersContents(let coordinator, let container):
            let viewModel = ContainerContentsViewModel(coordinator: coordinator, container: container)
            let view = ContainerContentsView(viewModel: viewModel)
            return AnyView(view)

        case .fileViewer(let item):
            let viewModel = FileViewerViewModel(item: item)
            let view = FileViewerView(viewModel: viewModel)
            return AnyView(view)

        case .saveContainer(let coordinator, let container):
            let viewModel = SaveContainerViewModel(coordinator: coordinator, container: container)
            let view = SaveContainerView(viewModel: viewModel)
            return AnyView(view)

        case .editContainerName(let coordinator, let mode):
            let viewModel = EditContainerNameViewModel(coordinator: coordinator, mode: mode)
            let view = EditContainerNameView(viewModel: viewModel)
            return AnyView(view)

        case .createContainerFiles(let coordinator, let name):
            let viewModel = CreateContainerFilesViewModel(coordinator: coordinator, name: name)
            let view = CreateContainerFilesView(viewModel: viewModel)
            return AnyView(view)

        case .createContainerSave(let coordinator, let name, let files):
            let viewModel = CreateContainerSaveViewModel(coordinator: coordinator, name: name, files: files)
            let view = CreateContainerSaveView(viewModel: viewModel)
            return AnyView(view)
        }
    }
}
