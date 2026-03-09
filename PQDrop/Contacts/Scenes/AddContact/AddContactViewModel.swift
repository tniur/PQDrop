//
//  AddContactViewModel.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 01.03.2026.
//

import Combine
import UIKit

@MainActor
final class AddContactViewModel: ObservableObject {

    // MARK: - Properties

    private let coordinator: ContactsCoordinatorProtocol
    
    private var isProcessing = false
    
    // MARK: - Initializer

    init(coordinator: ContactsCoordinatorProtocol) {
        self.coordinator = coordinator
    }

    // MARK: - Methods

    func handleScanned(value: String) {
        guard !isProcessing else { return }
        isProcessing = true
        showAddNameToContact(with: value)
    }

    func pasteFromClipboard() {
        guard !isProcessing else { return }
        guard let value = UIPasteboard.general.string, !value.isEmpty else { return }
        isProcessing = true
        showAddNameToContact(with: value)
    }

    func resetProcessing() {
        isProcessing = false
    }

    func showAddNameToContact(with id: String) {
        Task {
            await coordinator.showAddNameToContact(with: id)
        }
    }
}
