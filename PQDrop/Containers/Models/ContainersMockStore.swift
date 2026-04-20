//
//  ContainersMockStore.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 15.04.2026.
//

import Foundation

@MainActor
enum ContainersMockStore {

    static var preferredTab: ContainersTab = .created

    private(set) static var containers: [Container] = [
        .init(id: UUID(), containerID: Data(), name: "Название контейнера1", isAvailable: true, isOwned: true),
        .init(id: UUID(), containerID: Data(), name: "Название контейнера2", isAvailable: true, isOwned: true),
        .init(id: UUID(), containerID: Data(), name: "Название контейнера3", isAvailable: false, isOwned: true),
        .init(id: UUID(), containerID: Data(), name: "Название контейнера4", isAvailable: true, isOwned: true),
        .init(id: UUID(), containerID: Data(), name: "Полученный контейнер1", isAvailable: true, isOwned: false),
        .init(id: UUID(), containerID: Data(), name: "Полученный контейнер2", isAvailable: true, isOwned: false),
        .init(id: UUID(), containerID: Data(), name: "Полученный контейнер3", isAvailable: true, isOwned: false),
        .init(id: UUID(), containerID: Data(), name: "Полученный контейнер4", isAvailable: true, isOwned: false),
        .init(id: UUID(), containerID: Data(), name: "Полученный контейнер5", isAvailable: true, isOwned: false),
        .init(id: UUID(), containerID: Data(), name: "Полученный контейнер6", isAvailable: true, isOwned: false),
        .init(id: UUID(), containerID: Data(), name: "Полученный контейнер7", isAvailable: true, isOwned: false),
        .init(id: UUID(), containerID: Data(), name: "Полученный контейнер8", isAvailable: true, isOwned: false),
        .init(id: UUID(), containerID: Data(), name: "Полученный контейнер9", isAvailable: true, isOwned: false),
        .init(id: UUID(), containerID: Data(), name: "Полученный контейнер10", isAvailable: true, isOwned: false),
        .init(id: UUID(), containerID: Data(), name: "Полученный контейнер11", isAvailable: true, isOwned: false),
        .init(id: UUID(), containerID: Data(), name: "Полученный контейнер12", isAvailable: false, isOwned: false)
    ]

    static func addImportedContainer(from fileURL: URL, isAvailable: Bool) -> Container {
        let rawName = fileURL.deletingPathExtension().lastPathComponent
        let name = rawName.isEmpty ? "Импортированный контейнер" : rawName
        let container = Container(
            id: UUID(),
            containerID: Data(),
            name: name,
            isAvailable: isAvailable,
            isOwned: false
        )

        containers.insert(container, at: 4)
        preferredTab = .received
        return container
    }

    static func delete(container: Container) {
        containers.removeAll { $0.id == container.id }
    }
}
