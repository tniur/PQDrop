//
//  ContainerRepository.swift
//  PQDrop
//
//  Created by Pavel Bobkov on 19.04.2026.
//

import CoreData

final class ContainerRepository {
    private static let recipientPublicKeysEncoder = JSONEncoder()
    private static let recipientPublicKeysDecoder = JSONDecoder()
    private static let containersDirectoryName = "Containers"

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = PersistenceController.shared.viewContext) {
        self.context = context
    }

    func fetch(by id: UUID) -> Container? {
        fetchEntity(by: id).map(map)
    }

    func fetchAll() -> [Container] {
        let request = NSFetchRequest<ContainerEntity>(entityName: "ContainerEntity")
        request.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
        return (try? context.fetch(request))?.map(map) ?? []
    }

    func fetchOwned() -> [Container] {
        let request = NSFetchRequest<ContainerEntity>(entityName: "ContainerEntity")
        request.predicate = NSPredicate(format: "isOwned == YES")
        request.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
        return (try? context.fetch(request))?.map(map) ?? []
    }

    func fetchReceived() -> [Container] {
        let request = NSFetchRequest<ContainerEntity>(entityName: "ContainerEntity")
        request.predicate = NSPredicate(format: "isOwned == NO")
        request.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
        return (try? context.fetch(request))?.map(map) ?? []
    }

    func create(
        name: String,
        containerID: Data,
        fileURL: URL,
        isOwned: Bool,
        isAvailable: Bool,
        recipientPublicKeysRaw: [Data] = []
    ) throws -> Container {
        let entity = ContainerEntity(context: context)
        let now = Date()
        entity.id = UUID()
        entity.name = name
        entity.containerID = containerID
        entity.fileURL = storagePath(for: fileURL)
        entity.isOwned = isOwned
        entity.isAvailable = isAvailable
        entity.recipientPublicKeysRaw = encodeRecipientPublicKeys(recipientPublicKeysRaw)
        entity.createdAt = now
        entity.updatedAt = now
        try context.save()
        return map(entity)
    }

    func updateName(_ name: String, for id: UUID) throws {
        guard let entity = fetchEntity(by: id) else { return }
        entity.name = name
        entity.updatedAt = Date()
        try context.save()
    }

    func updateFileURL(_ fileURL: URL, for id: UUID) throws {
        guard let entity = fetchEntity(by: id) else { return }
        entity.fileURL = storagePath(for: fileURL)
        entity.updatedAt = Date()
        try context.save()
    }

    func updateAvailability(_ isAvailable: Bool, for id: UUID) throws {
        guard let entity = fetchEntity(by: id) else { return }
        entity.isAvailable = isAvailable
        entity.updatedAt = Date()
        try context.save()
    }

    func updateRecipientPublicKeys(_ recipientPublicKeysRaw: [Data], for id: UUID) throws {
        guard let entity = fetchEntity(by: id) else { return }
        entity.recipientPublicKeysRaw = encodeRecipientPublicKeys(recipientPublicKeysRaw)
        entity.updatedAt = Date()
        try context.save()
    }

    func delete(by id: UUID) throws {
        guard let entity = fetchEntity(by: id) else { return }
        context.delete(entity)
        try context.save()
    }

    private func fetchEntity(by id: UUID) -> ContainerEntity? {
        let request = NSFetchRequest<ContainerEntity>(entityName: "ContainerEntity")
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        return try? context.fetch(request).first
    }

    private func map(_ entity: ContainerEntity) -> Container {
        Container(
            id: entity.id ?? UUID(),
            containerID: entity.containerID ?? Data(),
            recipientPublicKeysRaw: decodeRecipientPublicKeys(entity.recipientPublicKeysRaw),
            name: entity.name ?? "",
            fileURL: resolveFileURL(from: entity.fileURL),
            isAvailable: entity.isAvailable,
            isOwned: entity.isOwned
        )
    }

    private func storagePath(for fileURL: URL) -> String {
        let standardizedURL = fileURL.standardizedFileURL

        guard let containersDirectory = Self.containersDirectory() else {
            return standardizedURL.lastPathComponent
        }

        let standardizedContainersDirectory = containersDirectory.standardizedFileURL
        let containersPath = standardizedContainersDirectory.path

        if standardizedURL.path == containersPath {
            return ""
        }

        let prefix = containersPath.hasSuffix("/") ? containersPath : containersPath + "/"
        if standardizedURL.path.hasPrefix(prefix) {
            return String(standardizedURL.path.dropFirst(prefix.count))
        }

        return standardizedURL.lastPathComponent
    }

    private func resolveFileURL(from storedPath: String?) -> URL? {
        guard let storedPath, !storedPath.isEmpty else {
            return nil
        }

        let fileManager = FileManager.default

        if !storedPath.hasPrefix("/") {
            guard let containersDirectory = Self.containersDirectory() else {
                return nil
            }

            let resolvedURL = containersDirectory.appendingPathComponent(storedPath)
            return fileManager.fileExists(atPath: resolvedURL.path) ? resolvedURL : nil
        }

        let absoluteURL = URL(fileURLWithPath: storedPath)
        if fileManager.fileExists(atPath: absoluteURL.path) {
            return absoluteURL
        }

        guard let containersDirectory = Self.containersDirectory() else {
            return nil
        }

        let pathComponents = absoluteURL.pathComponents
        if let containersIndex = pathComponents.lastIndex(of: Self.containersDirectoryName),
           containersIndex < pathComponents.index(before: pathComponents.endIndex) {
            let relativeComponents = pathComponents[(containersIndex + 1)...]
            let resolvedURL = relativeComponents.reduce(containersDirectory) { partialURL, component in
                partialURL.appendingPathComponent(component)
            }

            if fileManager.fileExists(atPath: resolvedURL.path) {
                return resolvedURL
            }
        }

        let fallbackURL = containersDirectory.appendingPathComponent(absoluteURL.lastPathComponent)
        return fileManager.fileExists(atPath: fallbackURL.path) ? fallbackURL : nil
    }

    private static func containersDirectory() -> URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent(containersDirectoryName, isDirectory: true)
    }

    private func encodeRecipientPublicKeys(_ recipientPublicKeysRaw: [Data]) -> Data? {
        try? Self.recipientPublicKeysEncoder.encode(recipientPublicKeysRaw)
    }

    private func decodeRecipientPublicKeys(_ data: Data?) -> [Data] {
        guard let data else { return [] }
        return (try? Self.recipientPublicKeysDecoder.decode([Data].self, from: data)) ?? []
    }
}
