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
    case qrCode(coordinator: ProfileCoordinatorProtocol)

    var presentationStyle: TransitionPresentationStyle { .push }

    var body: some View {
        switch self {
        case .profile(let coordinator):
            let keychainService = KeychainService()
            let keyPairManager = KeyPairManager(keychainService: keychainService)
            let viewModel = ProfileViewModel(coordinator: coordinator, keyPairManager: keyPairManager)
            let view = ProfileView(viewModel: viewModel)
            return AnyView(view)

        case .qrCode(let coordinator):
            let keychainService = KeychainService()
            let keyPairManager = KeyPairManager(keychainService: keychainService)
            let viewModel = ProfileQRCodeViewModel(coordinator: coordinator, keyPairManager: keyPairManager)
            let view = ProfileQRCodeView(viewModel: viewModel)
            return AnyView(view)
        }
    }
}
