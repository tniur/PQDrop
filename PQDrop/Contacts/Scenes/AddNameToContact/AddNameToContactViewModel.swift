//
//  AddNameToContactViewModel.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 01.03.2026.
//

import Combine

@MainActor
final class AddNameToContactViewModel: ObservableObject {
    
    // MARK: - Properties

    private var coordinator: ContactsCoordinatorProtocol
    private var id: String

    // MARK: - Initializer

    init(coordinator: ContactsCoordinatorProtocol, id: String) {
        self.coordinator = coordinator
        self.id = id
    }
}
