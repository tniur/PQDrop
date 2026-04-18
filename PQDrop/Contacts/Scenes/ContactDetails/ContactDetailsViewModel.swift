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
    @Published var showVerificationAlert = false
    
    private var pendingVerificationValue: Bool?
    
    var verifiedSelection: Binding<Int> {
        Binding(
            get: { [weak self] in
                guard let self else { return 1 }
                return self.contact.isVerified ? 0 : 1
            },
            set: { [weak self] newValue in
                self?.handleVerificationSelectionChange(newValue)
            }
        )
    }
    
    var fingerprintBlocks: [FingerprintBlock] {
        contact.fingerprint.chunked(into: 6)
    }
    
    var verificationAlertTitle: String {
        guard let pendingVerificationValue else { return "" }
        
        if pendingVerificationValue {
            return String(localized: "contacts.verification.alert.title.confirm")
        } else {
            return String(localized: "contacts.verification.alert.title.remove")
        }
    }
    
    var verificationAlertMessage: String {
        guard let pendingVerificationValue else { return "" }
        
        if pendingVerificationValue {
            return String(localized: "contacts.verification.alert.message.confirm")
        } else {
            return String(localized: "contacts.verification.alert.message.remove")
        }
    }
    
    var verificationConfirmButtonTitle: String {
        guard let pendingVerificationValue else { return "" }
        return pendingVerificationValue
        ? String(localized: "shared.confirm")
        : String(localized: "contacts.verification.remove")
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
    
    func confirmVerificationChange() {
        guard let pendingVerificationValue else { return }
        contact.isVerified = pendingVerificationValue
        self.pendingVerificationValue = nil
    }
    
    func cancelVerificationChange() {
        pendingVerificationValue = nil
    }
    
    private func handleVerificationSelectionChange(_ newValue: Int) {
        let newIsVerified = (newValue == 0)
        
        guard newIsVerified != contact.isVerified else { return }
        
        pendingVerificationValue = newIsVerified
        showVerificationAlert = true
    }
}
