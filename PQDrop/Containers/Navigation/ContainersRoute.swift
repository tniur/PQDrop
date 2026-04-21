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
    case importContainer(coordinator: ContainersCoordinatorProtocol, fileURL: URL)
    case recipientsSheet(recipients: [Recipient])
    case accessControl(coordinator: ContainersCoordinatorProtocol, container: Container)
    case containersContents(coordinator: ContainersCoordinatorProtocol, container: Container, decryptedDir: URL)
    case fileViewer(item: ContainerFileItem)
    case saveContainer(coordinator: ContainersCoordinatorProtocol, container: Container)
    case editContainerName(coordinator: ContainersCoordinatorProtocol, mode: EditContainerNameViewModel.Mode)
    case createContainerFiles(coordinator: ContainersCoordinatorProtocol, name: String)
    case createContainerSave(coordinator: ContainersCoordinatorProtocol, name: String, files: [ContainerFileItem])

    var presentationStyle: TransitionPresentationStyle {
        switch self {
        case .containers, .containerDetails, .importContainer, .accessControl, .containersContents, .fileViewer,
             .saveContainer, .editContainerName, .createContainerFiles, .createContainerSave:
            .push
        case .recipientsSheet:
            .sheet
        }
    }

    var body: some View {
        switch self {
        case .containers(let coordinator):
            let containerRepository = ContainerRepository()
            let viewModel = ContainersViewModel(coordinator: coordinator, containerRepository: containerRepository)
            let view = ContainersView(viewModel: viewModel)
            return AnyView(view)

        case .containerDetails(let coordinator, let container):
            let keychainService = KeychainService()
            let keyPairManager = KeyPairManager(keychainService: keychainService)
            let archiveService = ArchiveService()
            let containerService = ContainerService(archiveService: archiveService, keyPairManager: keyPairManager)
            let contactRepository = ContactRepository()
            let containerRepository = ContainerRepository()
            let historyRepository = HistoryRepository()
            let viewModel = ContainerDetailsViewModel(
                coordinator: coordinator,
                container: container,
                containerService: containerService,
                contactRepository: contactRepository,
                containerRepository: containerRepository,
                historyRepository: historyRepository,
                keyPairManager: keyPairManager
            )
            let view = ContainerDetailsView(viewModel: viewModel)
            return AnyView(view)

        case .importContainer(let coordinator, let fileURL):
            let keychainService = KeychainService()
            let keyPairManager = KeyPairManager(keychainService: keychainService)
            let archiveService = ArchiveService()
            let containerService = ContainerService(archiveService: archiveService, keyPairManager: keyPairManager)
            let containerRepository = ContainerRepository()
            let historyRepository = HistoryRepository()
            let viewModel = ImportContainerViewModel(
                coordinator: coordinator,
                containerService: containerService,
                containerRepository: containerRepository,
                historyRepository: historyRepository,
                keyPairManager: keyPairManager,
                fileURL: fileURL
            )
            let view = ImportContainerView(viewModel: viewModel)
            return AnyView(view)

        case .recipientsSheet(let recipients):
            let view = RecipientsSheetView(recipients: recipients)
            return AnyView(view)

        case .accessControl(let coordinator, let container):
            let keychainService = KeychainService()
            let keyPairManager = KeyPairManager(keychainService: keychainService)
            let archiveService = ArchiveService()
            let containerService = ContainerService(archiveService: archiveService, keyPairManager: keyPairManager)
            let contactRepository = ContactRepository()
            let historyRepository = HistoryRepository()
            let viewModel = AccessControlViewModel(
                coordinator: coordinator,
                container: container,
                containerService: containerService,
                contactRepository: contactRepository,
                historyRepository: historyRepository,
                keyPairManager: keyPairManager
            )
            let view = AccessControlView(viewModel: viewModel)
            return AnyView(view)

        case .containersContents(let coordinator, let container, let decryptedDir):
            let viewModel = ContainerContentsViewModel(
                coordinator: coordinator,
                container: container,
                decryptedDir: decryptedDir
            )
            let view = ContainerContentsView(viewModel: viewModel)
            return AnyView(view)

        case .fileViewer(let item):
            let viewModel = FileViewerViewModel(item: item)
            let view = FileViewerView(viewModel: viewModel)
            return AnyView(view)

        case .saveContainer(let coordinator, let container):
            let keychainService = KeychainService()
            let keyPairManager = KeyPairManager(keychainService: keychainService)
            let archiveService = ArchiveService()
            let containerService = ContainerService(archiveService: archiveService, keyPairManager: keyPairManager)
            let historyRepository = HistoryRepository()
            let contactRepository = ContactRepository()
            let viewModel = SaveContainerViewModel(
                coordinator: coordinator,
                container: container,
                containerService: containerService,
                historyRepository: historyRepository,
                contactRepository: contactRepository
            )
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
            let keychainService = KeychainService()
            let keyPairManager = KeyPairManager(keychainService: keychainService)
            let archiveService = ArchiveService()
            let containerService = ContainerService(archiveService: archiveService, keyPairManager: keyPairManager)
            let containerRepository = ContainerRepository()
            let historyRepository = HistoryRepository()
            let viewModel = CreateContainerSaveViewModel(
                coordinator: coordinator,
                containerService: containerService,
                containerRepository: containerRepository,
                historyRepository: historyRepository,
                name: name,
                files: files
            )
            let view = CreateContainerSaveView(viewModel: viewModel)
            return AnyView(view)
        }
    }
}
