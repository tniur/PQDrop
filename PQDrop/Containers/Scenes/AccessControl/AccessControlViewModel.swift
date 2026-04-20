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
    @Published var activeAlert: AccessControlAlert?

    var contacts: [Recipient] = [
        .init(id: "1", name: "Петя Иванов", fingerprint: "GK4gR7f8gF", isVerified: true),
        .init(id: "2", name: "Петя Иванов", fingerprint: "GK4gR7f8gF", isVerified: true),
        .init(id: "3", name: "Петя Иванов", fingerprint: "GK4gR7f8gF", isVerified: true),
    ]

    var hasSelection: Bool {
        !selectedContactIds.isEmpty
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
        activeAlert = hasSelection ? .applyAccessChanges : .noSelection
    }

    func applySelectedContacts() {
        hasAccessContactIds.formUnion(idsToGrant)
        selectedContactIds.removeAll()
        activeAlert = nil
    }

    func requestRevokeAccess(for id: String) {
        guard hasAccessContactIds.contains(id) else { return }
        activeAlert = .revokeAccess(contactId: id)
    }

    func revokeAccess(for id: String) {
        hasAccessContactIds.remove(id)
        selectedContactIds.remove(id)
        activeAlert = nil
    }
}
