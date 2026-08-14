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
    
    func updateStatus(
        profileID: String,
        status: MatchStatus
    ) async throws {
        
        updatedProfileID = profileID
        updatedStatus = status
    }
    func saveProfiles(
        _ profiles: [Profile]
    ) async throws {
        savedProfiles.append(contentsOf: profiles)
    }

    func fetchProfiles() async throws -> [Profile] {
        cachedProfiles
    }

}
