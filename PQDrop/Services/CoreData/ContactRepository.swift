//
//  ContactRepository.swift
//  PQDrop
//
//  Created by Pavel Bobkov on 19.04.2026.
//

import CoreData

final class ContactRepository {

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = PersistenceController.shared.viewContext) {
        self.context = context
    }

    func fetch(by id: UUID) -> Contact? {
        fetchEntity(by: id).map(map)
    }

    func fetchAll() -> [Contact] {
        let request = NSFetchRequest<ContactEntity>(entityName: "ContactEntity")
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        return (try? context.fetch(request))?.map(map) ?? []
    }

    func exists(publicKeyRaw: Data) -> Bool {
        let request = NSFetchRequest<ContactEntity>(entityName: "ContactEntity")
        request.predicate = NSPredicate(format: "publicKeyRaw == %@", publicKeyRaw as NSData)
        request.fetchLimit = 1
        return (try? context.count(for: request)) ?? 0 > 0
    }

    func create(name: String, publicKeyRaw: Data) throws -> Contact {
        let entity = ContactEntity(context: context)
        entity.id = UUID()
        entity.name = name
        entity.isVerified = false
        entity.publicKeyRaw = publicKeyRaw
        entity.createdAt = Date()
        try context.save()
        return map(entity)
    }

    func updateName(_ name: String, for id: UUID) throws {
        guard let entity = fetchEntity(by: id) else { return }
        entity.name = name
        try context.save()
    }

    func updateVerification(_ isVerified: Bool, for id: UUID) throws {
        guard let entity = fetchEntity(by: id) else { return }
        entity.isVerified = isVerified
        try context.save()
    }

    func delete(by id: UUID) throws {
        guard let entity = fetchEntity(by: id) else { return }
        context.delete(entity)
        try context.save()
    }

    func deleteAll() throws {
        let request = NSFetchRequest<ContactEntity>(entityName: "ContactEntity")
        let entities = try context.fetch(request)
        entities.forEach { context.delete($0) }
        try context.save()
    }

    private func fetchEntity(by id: UUID) -> ContactEntity? {
        let request = NSFetchRequest<ContactEntity>(entityName: "ContactEntity")
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        return try? context.fetch(request).first
    }

    private func map(_ entity: ContactEntity) -> Contact {
        Contact(
            id: entity.id ?? UUID(),
            name: entity.name ?? "",
            isVerified: entity.isVerified,
            publicKeyRaw: entity.publicKeyRaw ?? Data()
        )
    }
}
