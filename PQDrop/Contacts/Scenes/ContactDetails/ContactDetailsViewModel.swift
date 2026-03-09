//
//  ContactDetailsViewModel.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 04.03.2026.
//

import SwiftUI
import Combine
import UIKit

@MainActor
final class ContactDetailsViewModel: ObservableObject {
    
    // MARK: - Properties

    @Published var contact: Contact
    @Published var showDeleteAlert = false
    
    var verifiedSelection: Binding<Int> {
        Binding(
            get: { [weak self] in
                guard let self else { return 1 }
                return self.contact.isVerified ? 0 : 1
            },
            set: { [weak self] newValue in
                guard let self else { return }
                self.contact.isVerified = (newValue == 0)
            }
        )
    }
    
    var fingerprintBlocks: [FingerprintBlock] {
        contact.fingerprint.chunked(into: 6)
    }
    
    private let coordinator: ContactsCoordinatorProtocol
    
    // MARK: - Init

    init(coordinator: ContactsCoordinatorProtocol, contact: Contact) {
        self.coordinator = coordinator
        self.contact = contact
    }
    
    // MARK: - Methods

    func editName() {
        Task {
            await coordinator.showEditContactName(with: contact.id)
        }
    }
    
    func copyFingerprint() {
        UIPasteboard.general.string = contact.fingerprint
    }
    
    func deleteContact() {
        Task {
            await coordinator.finish()
        }
    }
}
