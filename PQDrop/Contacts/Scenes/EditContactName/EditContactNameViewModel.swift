//
//  EditContactNameViewModel.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 01.03.2026.
//

import Combine

@MainActor
final class EditContactNameViewModel: ObservableObject {
    
    // MARK: - Properties

    @Published var name: String = ""
    
    private let coordinator: ContactsCoordinatorProtocol
    private var id: String

    // MARK: - Initializer

    init(coordinator: ContactsCoordinatorProtocol, id: String) {
        self.coordinator = coordinator
        self.id = id
    }
    
    // MARK: - Methods
    
    func create() {
        Task {
            await coordinator.finish()
        }
    }
    
    func edit() {
        //поп на экран деталки контакта и сохранение нового имени
    }
}
