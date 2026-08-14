//
//  MockMatchesRepository.swift
//  MatchMate
//
//  Created by Abhishek Pathak on 14/08/26.
//


@testable import MatchMate

final class MockMatchesRepository: MatchesRepository {

    var fetchResult: Result<[Profile], Error> = .success([])

    var cachedProfiles: [Profile] = []

    var updatedProfileID: String?
    var updatedStatus: MatchStatus?

    func fetchProfiles(
        page: Int
    ) async throws -> [Profile] {
        try fetchResult.get()
    }

    func fetchCachedProfiles() async throws -> [Profile] {
        cachedProfiles
    }

    func updateStatus(
        profileID: String,
        status: MatchStatus
    ) async throws {

        updatedProfileID = profileID
        updatedStatus = status
    }
}