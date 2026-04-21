//
//  HistoryRepository.swift
//  PQDrop
//
//  Created by Pavel Bobkov on 20.04.2026.
//

import CoreData

final class HistoryRepository {

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = PersistenceController.shared.viewContext) {
        self.context = context
    }

    func append(
        type: HistoryEventType,
        containerID: Data,
        containerName: String,
        detail: String? = nil
    ) throws {
        let entity = HistoryEventEntity(context: context)
        entity.id = UUID()
        entity.type = type.rawValue
        entity.containerID = containerID
        entity.containerName = containerName
        entity.detail = detail
        entity.timestamp = Date()
        try context.save()
    }

    func fetchAll(filter: HistoryEventFilter = .all, retentionDays: Int = 90) -> [HistoryEvent] {
        let request = NSFetchRequest<HistoryEventEntity>(entityName: "HistoryEventEntity")
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]

        var predicates: [NSPredicate] = []

        let cutoffDate = Calendar.current.date(byAdding: .day, value: -retentionDays, to: Date()) ?? Date()
        predicates.append(NSPredicate(format: "timestamp >= %@", cutoffDate as NSDate))

        if filter != .all {
            let typeValues = typesForFilter(filter)
            predicates.append(NSPredicate(format: "type IN %@", typeValues))
        }

        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)

        return (try? context.fetch(request))?.compactMap(map) ?? []
    }

    func fetchForContainer(containerID: Data, filter: HistoryEventFilter = .all) -> [HistoryEvent] {
        let request = NSFetchRequest<HistoryEventEntity>(entityName: "HistoryEventEntity")
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]

        var predicates: [NSPredicate] = [
            NSPredicate(format: "containerID == %@", containerID as NSData)
        ]

        if filter != .all {
            let typeValues = typesForFilter(filter)
            predicates.append(NSPredicate(format: "type IN %@", typeValues))
        }

        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)

        return (try? context.fetch(request))?.compactMap(map) ?? []
    }

    func deleteOlderThan(days: Int) throws {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        let request = NSFetchRequest<HistoryEventEntity>(entityName: "HistoryEventEntity")
        request.predicate = NSPredicate(format: "timestamp < %@", cutoffDate as NSDate)
        let entities = try context.fetch(request)
        entities.forEach { context.delete($0) }
        try context.save()
    }

    func groupBySections(_ events: [HistoryEvent]) -> [HistoryEventSection] {
        let grouped = Dictionary(grouping: events) { $0.dateTitle }
        let sortedKeys = grouped.keys.sorted { key1, key2 in
            guard let first = grouped[key1]?.first, let second = grouped[key2]?.first else {
                return false
            }
            return first.timestamp > second.timestamp
        }
        return sortedKeys.map { key in
            HistoryEventSection(dateTitle: key, events: grouped[key] ?? [])
        }
    }

    private func typesForFilter(_ filter: HistoryEventFilter) -> [String] {
        switch filter {
        case .all:
            return HistoryEventType.allCases.map(\.rawValue)
        case .export:
            return [HistoryEventType.export.rawValue]
        case .imported:
            return [HistoryEventType.imported.rawValue]
        case .access:
            return [HistoryEventType.accessGranted.rawValue, HistoryEventType.accessRevoked.rawValue]
        }
    }

    private func map(_ entity: HistoryEventEntity) -> HistoryEvent? {
        guard let type = HistoryEventType(rawValue: entity.type ?? "") else { return nil }

        return HistoryEvent(
            id: entity.id ?? UUID(),
            type: type,
            containerName: entity.containerName ?? "",
            containerID: entity.containerID ?? Data(),
            detail: entity.detail,
            timestamp: entity.timestamp ?? Date()
        )
    }
}
