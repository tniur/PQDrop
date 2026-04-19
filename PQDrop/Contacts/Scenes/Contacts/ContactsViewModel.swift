//
//  ContactsViewModel.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 27.02.2026.
//

import Combine
import Foundation

@MainActor
final class ContactsViewModel: ObservableObject {
    
    // MARK: - Properties
    
    @Published var searchText: String = ""
    @Published var filter: ContactsFilter = .all
    @Published var contactToDelete: Contact? = nil
    @Published var showClearAlert = false

    var filteredContacts: [Contact] {
        let base: [Contact]
        switch filter {
        case .all:
            base = contacts
        case .verifiedOnly:
            base = contacts.filter { $0.isVerified }
        case .unverifiedOnly:
            base = contacts.filter { !$0.isVerified }
        }
        
        guard !searchText.isEmpty else { return base }
        return base.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    private var contacts: [Contact] = []
    
    private let coordinator: ContactsCoordinatorProtocol
    private let contactRepository: ContactRepository
    
    // MARK: - Initializer

    init(coordinator: ContactsCoordinatorProtocol, contactRepository: ContactRepository) {
        self.coordinator = coordinator
        self.contactRepository = contactRepository
    }
    
    // MARK: - Methods

    func loadContacts() {
        contacts = contactRepository.fetchAll()
    }

    func showFilters() {
        Task {
            let model = ContactsFilterSheetModel(currentFilter: filter) { filter in
                self.filter = filter
            }
            await coordinator.showContactsFilterSheet(with: model)
        }
    }

    func addContact() {
        Task {
            await coordinator.showAddContact()
        }
    }
    
    func delete(contact: Contact) {
        try? contactRepository.delete(by: contact.id)
        loadContacts()
    }
    
    func clearContacts() {
        try? contactRepository.deleteAll()
        loadContacts()
    }
    
    func showDetails(of contact: Contact) {
        Task {
            await coordinator.showContactDetails(with: contact)
        }
    }
}
