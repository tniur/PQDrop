//
//  PersistenceController.swift
//  PQDrop
//
//  Created by Pavel Bobkov on 19.04.2026.
//

import CoreData

final class PersistenceController {

    static let shared = PersistenceController()

    let container: NSPersistentContainer

    var viewContext: NSManagedObjectContext { container.viewContext }

    init() {
        container = NSPersistentContainer(name: "PQDrop")
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.loadPersistentStores { _, error in
            if let error {
                fatalError("Core Data failed to load: \(error)")
            }
        }
    }
}
