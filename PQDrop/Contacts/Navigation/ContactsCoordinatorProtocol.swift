//
//  ContactsCoordinatorProtocol.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 27.02.2026.
//

import Foundation

protocol ContactsCoordinatorProtocol: AnyObject {
    func showContactsFilterSheet(with model: ContactsFilterSheetModel) async
    func showAddContact() async
    func showEditContactName(publicKeyData: Data) async
    func showEditContactName(contactId: UUID) async
    func showContactDetails(with contact: Contact) async
    func finish() async
}
