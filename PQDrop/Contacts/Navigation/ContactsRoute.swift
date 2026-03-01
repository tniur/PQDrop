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
    
    var presentationStyle: TransitionPresentationStyle {
        switch self {
        case .contacts:
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
        }
    }
}
