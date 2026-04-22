//
//  ProfileRoute.swift
//  PQDrop
//
//  Created by Pavel Bobkov on 19.04.2026.
//

import SwiftUI
import SUICoordinator

enum ProfileRoute: RouteType {
    case profile(coordinator: ProfileCoordinatorProtocol)

    var presentationStyle: TransitionPresentationStyle { .push }

    var body: some View {
        switch self {
        case .profile:
            let keychainService = KeychainService()
            let keyPairManager = KeyPairManager(keychainService: keychainService)
            let containerRepository = ContainerRepository()
            let contactRepository = ContactRepository()
            let historyRepository = HistoryRepository()
            let viewModel = ProfileViewModel(
                keyPairManager: keyPairManager,
                containerRepository: containerRepository,
                contactRepository: contactRepository,
                historyRepository: historyRepository
            )
            let view = ProfileView(viewModel: viewModel)
            return AnyView(view)
        }
    }
}
