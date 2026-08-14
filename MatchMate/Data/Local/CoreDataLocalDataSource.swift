//
//  CoreDataLocalDataSource.swift
//  MatchMate
//
//  Created by Abhishek Pathak on 14/08/26.
//


import CoreData

final class CoreDataLocalDataSource: LocalDataSource {

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func fetchProfiles() async throws -> [Profile] {
        
        let request = ProfileEntity.fetchRequest()
        
        let entities = try context.fetch(request)
        
        return try entities.map { entity in
            try entity.toDomain()
        }
    }

    func saveProfiles(_ profiles: [Profile]) async throws {
        
        for profile in profiles {
            
            let request = ProfileEntity.fetchRequest()
            request.fetchLimit = 1
            request.predicate = NSPredicate(
                format: "id == %@",
                profile.id
            )
            
            if let existingEntity = try context.fetch(request).first {
                
                // API refreshes server data,
                // but preserve locally stored match status.
                existingEntity.update(
                    from: profile,
                    updateStatus: false
                )
                
            } else {
                
                // New profile gets the API/default status.
                let entity = ProfileEntity(context: context)
                
                entity.update(
                    from: profile
                )
            }
        }
        
        if context.hasChanges {
            try context.save()
        }
    }

    func updateStatus(
        profileID: String,
        status: MatchStatus
    ) async throws {
        
        let request = ProfileEntity.fetchRequest()
        
        request.fetchLimit = 1
        request.predicate = NSPredicate(
            format: "id == %@",
            profileID
        )
        
        guard let entity = try context.fetch(request).first else {
            throw PersistenceError.profileNotFound
        }
        
        entity.matchStatus = status.rawValue
        
        try context.save()
    }
}
