//
//  ContactsRoute.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 27.02.2026.
//

import SwiftUI
import SUICoordinator

enum ContactsRoute: RouteType {
    case contacts(coordinator: ContactsCoordinatorProtocol)
    case contactsFiltersSheet(model: ContactsFilterSheetModel)
    case addContact(coordinator: ContactsCoordinatorProtocol)
    case createContactName(coordinator: ContactsCoordinatorProtocol, publicKeyData: Data)
    case editContactName(coordinator: ContactsCoordinatorProtocol, contactId: UUID)
    case contactDetails(coordinator: ContactsCoordinatorProtocol, contact: Contact)
    
    var presentationStyle: TransitionPresentationStyle {
        switch self {
        case .contacts, .addContact, .createContactName, .editContactName, .contactDetails:
            .push
        case .contactsFiltersSheet:
            .sheet
        }
    }

    var body: some View {
        switch self {
        case .contacts(let coordinator):
            let contactRepository = ContactRepository()
            let containerRepository = ContainerRepository()
            let keychainService = KeychainService()
            let keyPairManager = KeyPairManager(keychainService: keychainService)
            let archiveService = ArchiveService()
            let containerService = ContainerService(archiveService: archiveService, keyPairManager: keyPairManager)
            let viewModel = ContactsViewModel(
                coordinator: coordinator,
                contactRepository: contactRepository,
                containerRepository: containerRepository,
                containerService: containerService
            )
            let view = ContactsView(viewModel: viewModel)
            return AnyView(view)
            
        case .contactsFiltersSheet(let model):
            let view = ContactsFilterSheet(model: model)
            return AnyView(view)
            
        case .addContact(let coordinator):
            let contactRepository = ContactRepository()
            let viewModel = AddContactViewModel(coordinator: coordinator, contactRepository: contactRepository)
            let view = AddContactView(viewModel: viewModel)
            return AnyView(view)
            
        case .createContactName(let coordinator, let publicKeyData):
            let contactRepository = ContactRepository()
            let viewModel = EditContactNameViewModel(coordinator: coordinator, contactRepository: contactRepository, mode: .create(publicKeyData: publicKeyData))
            let view = EditContactNameView(viewModel: viewModel)
            return AnyView(view)
            
        case .editContactName(let coordinator, let contactId):
            let contactRepository = ContactRepository()
            let viewModel = EditContactNameViewModel(coordinator: coordinator, contactRepository: contactRepository, mode: .edit(contactId: contactId))
            let view = EditContactNameView(viewModel: viewModel)
            return AnyView(view)
            
        case .contactDetails(let coordinator, let contact):
            let contactRepository = ContactRepository()
            let containerRepository = ContainerRepository()
            let keychainService = KeychainService()
            let keyPairManager = KeyPairManager(keychainService: keychainService)
            let archiveService = ArchiveService()
            let containerService = ContainerService(archiveService: archiveService, keyPairManager: keyPairManager)
            let viewModel = ContactDetailsViewModel(
                coordinator: coordinator,
                contact: contact,
                contactRepository: contactRepository,
                containerRepository: containerRepository,
                containerService: containerService
            )
            let view = ContactDetailsView(viewModel: viewModel)
            return AnyView(view)
        }
    }
}
