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
        contact.fingerprint
            .components(separatedBy: " ")
            .enumerated()
            .map { FingerprintBlock(id: $0.offset, text: $0.element) }
    }
    
    var verificationAlertTitle: String {
        guard let pendingVerificationValue else { return "" }
        
        if pendingVerificationValue {
            return "Подтвердить контакт как Verified?"
        } else {
            return "Удалить верификацию контакта?"
        }
    }
    
    var verificationAlertMessage: String {
        guard let pendingVerificationValue else { return "" }
        
        if pendingVerificationValue {
            return "Вы подтверждаете, что сверили fingerprint по независимому каналу."
        } else {
            return "Этот ключ больше не считается проверенным."
        }
    }
    
    var verificationConfirmButtonTitle: String {
        guard let pendingVerificationValue else { return "" }
        return pendingVerificationValue ? "Подтвердить" : "Удалить верификацию"
    }
    
    private let coordinator: ContactsCoordinatorProtocol
    private let contactRepository: ContactRepository
    
    // MARK: - Init

    init(coordinator: ContactsCoordinatorProtocol, contact: Contact, contactRepository: ContactRepository) {
        self.coordinator = coordinator
        self.contact = contact
        self.contactRepository = contactRepository
    }
    
    // MARK: - Methods

    func editName() {
        Task {
            await coordinator.showEditContactName(contactId: contact.id)
        }
    }
    
    func copyFingerprint() {
        UIPasteboard.general.string = contact.fingerprint
    }
    
    func deleteContact() {
        try? contactRepository.delete(by: contact.id)
        Task {
            await coordinator.finish()
        }
    }
    
    func confirmVerificationChange() {
        guard let pendingVerificationValue else { return }
        contact.isVerified = pendingVerificationValue
        try? contactRepository.updateVerification(pendingVerificationValue, for: contact.id)
        self.pendingVerificationValue = nil
    }
    
    func cancelVerificationChange() {
        pendingVerificationValue = nil
    }

    // MARK: - Private

    private func handleVerificationSelectionChange(_ newValue: Int) {
        let newIsVerified = (newValue == 0)
        
        guard newIsVerified != contact.isVerified else { return }
        
        pendingVerificationValue = newIsVerified
        showVerificationAlert = true
    }
}
