//
//  MockLocalDataSource.swift
//  MatchMate
//
//  Created by Abhishek Pathak on 14/08/26.
//

@testable import MatchMate

final class MockLocalDataSource: LocalDataSource {
    
    var savedProfiles: [Profile] = []
    var cachedProfiles: [Profile] = []
    var updatedProfileID: String?
    var updatedStatus: MatchStatus?
    func saveProfiles(_ profiles: [Profile]) async throws {
        savedProfiles.append(contentsOf: profiles)
        
        for profile in profiles {
            if let index = cachedProfiles.firstIndex(
                where: { $0.id == profile.id }
            ) {
                // Simulate Core Data preserving local status.
                let existingStatus = cachedProfiles[index].matchStatus
                
                var updatedProfile = profile
                updatedProfile.matchStatus = existingStatus
                
                cachedProfiles[index] = updatedProfile
            } else {
                cachedProfiles.append(profile)
            }
        }
    }
    
    func fetchProfiles() async throws -> [Profile] {
        cachedProfiles
    }
    
    func updateStatus(
        profileID: String,
        status: MatchStatus
    ) async throws {
        
        guard let index = cachedProfiles.firstIndex(
            where: { $0.id == profileID }
        ) else {
            throw PersistenceError.profileNotFound
        }
        updatedProfileID = profileID
        updatedStatus = status
        cachedProfiles[index].matchStatus = status
    }
}
