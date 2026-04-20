//
//  ContainerRepository.swift
//  PQDrop
//
//  Created by Pavel Bobkov on 19.04.2026.
//

import CoreData

final class ContainerRepository {

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
        isAvailable: Bool
    ) throws -> Container {
        let entity = ContainerEntity(context: context)
        let now = Date()
        entity.id = UUID()
        entity.name = name
        entity.containerID = containerID
        entity.fileURL = fileURL.path
        entity.isOwned = isOwned
        entity.isAvailable = isAvailable
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
        entity.fileURL = fileURL.path
        entity.updatedAt = Date()
        try context.save()
    }

    func updateAvailability(_ isAvailable: Bool, for id: UUID) throws {
        guard let entity = fetchEntity(by: id) else { return }
        entity.isAvailable = isAvailable
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
            name: entity.name ?? "",
            fileURL: URL(fileURLWithPath: entity.fileURL ?? ""),
            isAvailable: entity.isAvailable,
            isOwned: entity.isOwned
        )
    }
}
