//
//  PersistenceController.swift
//  MatchMate
//
//  Created by Abhishek Pathak on 14/08/26.
//


import CoreData

final class PersistenceController {

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {

        container = NSPersistentContainer(
            name: "MatchMateModel"
        )

        if inMemory {
            container.persistentStoreDescriptions.first?
                .url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { _, error in
            if let error {
                fatalError(
                    "Failed to load persistent store: \(error)"
                )
            }
        }
    }
}
