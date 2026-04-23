//
//  EditContactNameViewModel.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 01.03.2026.
//

import Combine
import Foundation

@MainActor
final class EditContactNameViewModel: ObservableObject {
    
    // MARK: - Types

    enum Mode {
        case create(publicKeyData: Data)
        case edit(contactId: UUID)
    }

    // MARK: - Properties

    @Published var name: String = ""
    
    var buttonTitle: String {
        switch mode {
        case .create: String(localized: "shared.create")
        case .edit: String(localized: "shared.save")
        }
    }

    private let coordinator: ContactsCoordinatorProtocol
    private let contactRepository: ContactRepository
    private let mode: Mode

    // MARK: - Initializer

    init(coordinator: ContactsCoordinatorProtocol, contactRepository: ContactRepository, mode: Mode) {
        self.coordinator = coordinator
        self.contactRepository = contactRepository
        self.mode = mode

        if case .edit(let contactId) = mode, let contact = contactRepository.fetch(by: contactId) {
            self.name = contact.name
        }
    }
    
    // MARK: - Methods
    
    func save() {
        switch mode {
        case .create(let publicKeyData):
            _ = try? contactRepository.create(name: name, publicKeyRaw: publicKeyData)
            Task {
                await coordinator.finish()
            }
        case .edit(let contactId):
            try? contactRepository.updateName(name, for: contactId)
            Task {
                await coordinator.pop()
            }
        }
    }
}
