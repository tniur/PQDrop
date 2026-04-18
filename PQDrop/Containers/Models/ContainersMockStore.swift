//
//  ContainersMockStore.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 15.04.2026.
//

import Foundation

@MainActor
enum ContainersMockStore {

    // MARK: - Properties

    static var preferredTab: ContainersTab = .created

    private static var importedIndex = 17

    private(set) static var containers: [Container] = [
        .init(id: "100000001", name: "Название контейнера", isAvailable: true, isCreated: true),
        .init(id: "100000002", name: "Название контейнера", isAvailable: true, isCreated: true),
        .init(id: "100000003", name: "Название контейнера", isAvailable: false, isCreated: true),
        .init(id: "100000004", name: "Название контейнера", isAvailable: true, isCreated: true),
        .init(id: "200000005", name: "Полученный контейнер", isAvailable: true, isCreated: false),
        .init(id: "200000006", name: "Полученный контейнер", isAvailable: true, isCreated: false),
        .init(id: "200000007", name: "Полученный контейнер", isAvailable: true, isCreated: false),
        .init(id: "200000008", name: "Полученный контейнер", isAvailable: true, isCreated: false),
        .init(id: "200000009", name: "Полученный контейнер", isAvailable: true, isCreated: false),
        .init(id: "200000010", name: "Полученный контейнер", isAvailable: true, isCreated: false),
        .init(id: "200000011", name: "Полученный контейнер", isAvailable: true, isCreated: false),
        .init(id: "200000012", name: "Полученный контейнер", isAvailable: true, isCreated: false),
        .init(id: "200000013", name: "Полученный контейнер", isAvailable: true, isCreated: false),
        .init(id: "200000014", name: "Полученный контейнер", isAvailable: true, isCreated: false),
        .init(id: "200000015", name: "Полученный контейнер", isAvailable: true, isCreated: false),
        .init(id: "200000016", name: "Полученный контейнер", isAvailable: false, isCreated: false)
    ]

    // MARK: - Methods

    static func addImportedContainer(from fileURL: URL, isAvailable: Bool) -> Container {
        let id = String(format: "200000%03d", importedIndex)
        importedIndex += 1

        let rawName = fileURL.deletingPathExtension().lastPathComponent
        let name = rawName.isEmpty ? String(localized: "containers.imported.default.name") : rawName
        let container = Container(
            id: id,
            name: name,
            isAvailable: isAvailable,
            isCreated: false
        )

        containers.insert(container, at: 4)
        preferredTab = .received
        return container
    }

    static func delete(container: Container) {
        containers.removeAll { $0.id == container.id }
    }
}
