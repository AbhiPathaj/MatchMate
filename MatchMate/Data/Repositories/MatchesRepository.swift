//
//  MatchesRepository.swift
//  MatchMate
//
//  Created by Abhishek Pathak on 14/08/26.
//


nonisolated protocol MatchesRepository {

    func fetchProfiles(page: Int) async throws -> [Profile]

    func fetchCachedProfiles() async throws -> [Profile]

    func updateStatus(
        profileID: String,
        status: MatchStatus
    ) async throws
}
