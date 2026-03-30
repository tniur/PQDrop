//
//  AccessControlViewModel.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 22.03.2026.
//

import Combine

@MainActor
final class AccessControlViewModel: ObservableObject {

    // MARK: - Properties

    @Published var container: Container
    @Published var hasAccessContactIds: Set<String> = []
    @Published var selectedContactIds: Set<String> = []
    @Published var isShowingApplyAlert = false

    var contacts: [Recipient] = [
        .init(id: "1", name: "Петя Иванов", publicKey: "GK4gR7f8gF", isVerified: true),
        .init(id: "2", name: "Петя Иванов", publicKey: "GK4gR7f8gF", isVerified: true),
        .init(id: "3", name: "Петя Иванов", publicKey: "GK4gR7f8gF", isVerified: true),
    ]

    var hasSelection: Bool {
        !selectedContactIds.isEmpty
    }

    var hasPendingChanges: Bool {
        !idsToGrant.isEmpty
    }

    var alertTitle: String {
        if hasSelection {
            return "Выбрано \(selectedContactIds.count) из \(contacts.count) контактов"
        } else {
            return "Контакт не выбран"
        }
    }

    var alertMessage: String {
        if hasSelection, hasPendingChanges {
            return "Добавление получателей требует перешифровки контейнера. Это может занять несколько минут."
        } else if hasSelection {
            return "Нет изменений для применения."
        } else {
            return "Выберите хотя бы один контакт, чтобы выдать доступ к контейнеру."
        }
    }

    private var idsToGrant: Set<String> {
        selectedContactIds.subtracting(hasAccessContactIds)
    }
    
    private let coordinator: ContainersCoordinatorProtocol

    // MARK: - Init

    init(coordinator: ContainersCoordinatorProtocol, container: Container) {
        self.coordinator = coordinator
        self.container = container
    }
    
    // MARK: - Methods

    func isSelected(_ id: String) -> Bool {
        selectedContactIds.contains(id)
    }

    func hasAccess(_ id: String) -> Bool {
        hasAccessContactIds.contains(id)
    }

    func toggleContact(_ id: String) {
        guard !hasAccessContactIds.contains(id) else { return }

        if selectedContactIds.contains(id) {
            selectedContactIds.remove(id)
        } else {
            selectedContactIds.insert(id)
        }
    }

    func addContact() {
        isShowingApplyAlert = true
    }

    func applySelectedContacts() {
        hasAccessContactIds.formUnion(idsToGrant)
        selectedContactIds.removeAll()
        isShowingApplyAlert = false
    }
}
