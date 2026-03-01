//
//  ContactsCoordinator.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 27.02.2026.
//

import SwiftUI
import SUICoordinator

@MainActor
final class ContactsCoordinator: Coordinator<ContactsRoute>, ContactsCoordinatorProtocol {

    override init() {
        super.init()
        Task { [weak self] in
            await self?.start()
        }
    }

    override func start() async {
        await startFlow(route: .contacts(coordinator: self))
    }
    
    func showContactsFilterSheet(with model: ContactsFilterSheetModel) async {
        await navigate(toRoute: .contactsFiltersSheet(model: model))
    }
}

