//
//  DefaultMatchesRepository.swift
//  MatchMate
//
//  Created by Abhishek Pathak on 14/08/26.
//

import Foundation

nonisolated final class DefaultMatchesRepository: MatchesRepository {
    
    private let remoteService: RandomUserService
    private let localDataSource: LocalDataSource
    
    init(
        remoteService: RandomUserService,
        localDataSource: LocalDataSource
    ) {
        self.remoteService = remoteService
        self.localDataSource = localDataSource
    }
    
    func fetchProfiles(
        page: Int
    ) async throws -> [Profile] {
        
        do {
            let profiles = try await remoteService.fetchProfiles(
                page: page
            )
            
            try await localDataSource.saveProfiles(
                profiles
            )
            
            // Important: return the persisted version,
            // because Core Data owns local matchStatus.
            return try await localDataSource.fetchProfiles()
            
        } catch {
            
            // Remote unavailable → use cached profiles.
            let cachedProfiles = try await localDataSource.fetchProfiles()
            
            if !cachedProfiles.isEmpty {
                return cachedProfiles
            }
            
            throw error
        }
    }
    
    func fetchCachedProfiles() async throws -> [Profile] {
        
        try await localDataSource.fetchProfiles()
    }
    
    func updateStatus(
        profileID: String,
        status: MatchStatus
    ) async throws {
        
        try await localDataSource.updateStatus(
            profileID: profileID,
            status: status
        )
    }
}
