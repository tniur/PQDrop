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
    
    @Published private var contacts: [Contact] = []
    
    private let coordinator: ContactsCoordinatorProtocol
    private let contactRepository: ContactRepository
    private let containerRepository: ContainerRepository
    private let containerService: ContainerService
    
    // MARK: - Initializer

    init(
        coordinator: ContactsCoordinatorProtocol,
        contactRepository: ContactRepository,
        containerRepository: ContainerRepository,
        containerService: ContainerService
    ) {
        self.coordinator = coordinator
        self.contactRepository = contactRepository
        self.containerRepository = containerRepository
        self.containerService = containerService
        loadContacts()
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
            loadContacts()
        }
    }
    
    func delete(contact: Contact) {
        preserveRecipientKeys(for: [contact])
        try? contactRepository.delete(by: contact.id)
        loadContacts()
    }
    
    func clearContacts() {
        preserveRecipientKeys(for: contacts)
        try? contactRepository.deleteAll()
        loadContacts()
    }
    
    func showDetails(of contact: Contact) {
        Task {
            await coordinator.showContactDetails(with: contact)
            loadContacts()
        }
    }

    private func preserveRecipientKeys(for contacts: [Contact]) {
        guard !contacts.isEmpty else { return }

        let candidateRecipientPublicKeysRaw = contacts.map(\.publicKeyRaw)

        for container in containerRepository.fetchAll() {
            guard let fileURL = container.fileURL else {
                continue
            }

            guard let recoveredRawKeys = try? containerService.mergedCurrentNonOwnerRecipientPublicKeys(
                at: fileURL,
                storedRecipientPublicKeysRaw: container.recipientPublicKeysRaw,
                candidateRecipientPublicKeysRaw: candidateRecipientPublicKeysRaw
            ) else {
                continue
            }

            guard recoveredRawKeys != container.recipientPublicKeysRaw else {
                continue
            }

            try? containerRepository.updateRecipientPublicKeys(recoveredRawKeys, for: container.id)
        }
    }
}
