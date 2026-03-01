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
    case addNameToContact(coordinator: ContactsCoordinatorProtocol, id: String)
    
    var presentationStyle: TransitionPresentationStyle {
        switch self {
        case .contacts, .addContact, .addNameToContact:
            .push
        case .contactsFiltersSheet:
            .sheet
        }
    }

    var body: some View {
        switch self {
        case .contacts(let coordinator):
            let viewModel = ContactsViewModel(coordinator: coordinator)
            let view = ContactsView(viewModel: viewModel)
            return AnyView(view)
            
        case .contactsFiltersSheet(let model):
            let view = ContactsFilterSheet(model: model)
            return AnyView(view)
            
        case .addContact(let coordinator):
            let viewModel = AddContactViewModel(coordinator: coordinator)
            let view = AddContactView(viewModel: viewModel)
            return AnyView(view)
            
        case .addNameToContact(let coordinator, let id):
            let viewModel = AddNameToContactViewModel(coordinator: coordinator, id: id)
            let view = AddNameToContactView(viewModel: viewModel)
            return AnyView(view)
        }
    }
}
