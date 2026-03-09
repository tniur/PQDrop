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
    
    func showAddContact() async {
        await navigate(toRoute: .addContact(coordinator: self))
    }
    
    func showAddNameToContact(with id: String) async {
        await navigate(toRoute: .addNameToContact(coordinator: self, id: id))
    }
    
    func showContactDetails(with contact: Contact) async {
        await navigate(toRoute: .contactDetails(coordinator: self, contact: contact))
    }
    
    func finish() async {
        await restart()
    }
}

