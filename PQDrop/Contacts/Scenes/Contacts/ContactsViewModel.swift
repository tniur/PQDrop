//
//  ContactsViewModel.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 27.02.2026.
//

import Combine

final class ContactsViewModel: ObservableObject {
    
    // MARK: - Properties

    @Published var contacts: [Contact] = [
        .init(id: "0", name: "odoaosd", isVerified: true),
        .init(id: "1", name: "smdks", isVerified: false),
        .init(id: "2", name: "smdks", isVerified: false),
        .init(id: "3", name: "smdks", isVerified: true),
        .init(id: "4", name: "smdks", isVerified: true),
        .init(id: "5", name: "smdks", isVerified: false),
        .init(id: "6", name: "smdks", isVerified: false),
        .init(id: "7", name: "smdks", isVerified: true),
        .init(id: "8", name: "smdks", isVerified: true),
        .init(id: "9", name: "smdks", isVerified: true),
        .init(id: "10", name: "smdks", isVerified: false),
        .init(id: "11", name: "smdks", isVerified: true)
    ]
    
    @Published var searchText: String = ""
    
    private let coordinator: ContactsCoordinatorProtocol
    
    // MARK: - Initializer

    init(coordinator: ContactsCoordinatorProtocol) {
        self.coordinator = coordinator
    }
    
    // MARK: - Methods

    func showFilters() {
        
    }
    
    func showSettings() {
        
    }
    
    func addContact() {
        
    }
}
