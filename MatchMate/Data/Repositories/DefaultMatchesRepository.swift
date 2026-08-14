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
        
        let profiles = try await remoteService.fetchProfiles(
            page: page
        )
        
        try await localDataSource.saveProfiles(
            profiles
        )
        
        return profiles
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
