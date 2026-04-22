//
//  AddContactViewModel.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 01.03.2026.
//

import Combine
import UIKit
import PQContainerKit

@MainActor
final class AddContactViewModel: ObservableObject {

    // MARK: - Properties

    @Published var showErrorAlert = false
    @Published var errorMessage = ""
    
    private var isProcessing = false
    
    private let coordinator: ContactsCoordinatorProtocol
    private let contactRepository: ContactRepository
    
    // MARK: - Initializer

    init(coordinator: ContactsCoordinatorProtocol, contactRepository: ContactRepository) {
        self.coordinator = coordinator
        self.contactRepository = contactRepository
    }

    // MARK: - Methods

    func handleScanned(value: String) {
        guard !isProcessing else { return }
        isProcessing = true
        validateAndProceed(with: value)
    }

    func pasteFromClipboard() {
        guard !isProcessing else { return }
        guard let value = UIPasteboard.general.string, !value.isEmpty else { return }
        isProcessing = true
        validateAndProceed(with: value)
    }

    func resetProcessing() {
        isProcessing = false
    }

    // MARK: - Private

    private func validateAndProceed(with value: String) {
        do {
            let pubKey = try XWing.PublicKey(base64: value)

            if contactRepository.exists(publicKeyRaw: pubKey.rawRepresentation) {
                showError(String(localized: "contacts.add.error.duplicate"))
                return
            }

            Task {
                await coordinator.showEditContactName(publicKeyData: pubKey.rawRepresentation)
            }
        } catch {
            showError(String(localized: "contacts.add.error.invalid.key"))
        }
    }
    
    private func showError(_ message: String) {
        errorMessage = message
        showErrorAlert = true
        isProcessing = false
    }
}
