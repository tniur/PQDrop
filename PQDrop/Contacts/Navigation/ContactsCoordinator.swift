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
    
    func showEditContactName(publicKeyData: Data) async {
        await navigate(toRoute: .createContactName(coordinator: self, publicKeyData: publicKeyData))
    }

    func showEditContactName(contactId: UUID) async {
        await navigate(toRoute: .editContactName(coordinator: self, contactId: contactId))
    }
    
    func showContactDetails(with contact: Contact) async {
        await navigate(toRoute: .contactDetails(coordinator: self, contact: contact))
    }
    
    func finish() async {
        await restart()
    }
}

