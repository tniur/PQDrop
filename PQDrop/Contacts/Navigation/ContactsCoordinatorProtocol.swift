//
//  ContactsCoordinatorProtocol.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 27.02.2026.
//

protocol ContactsCoordinatorProtocol: AnyObject {
    func showContactsFilterSheet(with model: ContactsFilterSheetModel) async
    func showAddContact() async
    func showAddNameToContact(with id: String) async
    func finish() async 
}
