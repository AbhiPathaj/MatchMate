//
//  LocalDataSource.swift
//  MatchMate
//
//  Created by Abhishek Pathak on 14/08/26.
//


import Foundation

protocol LocalDataSource {

    func fetchProfiles() async throws -> [Profile]

    func saveProfiles(_ profiles: [Profile]) async throws

    func updateStatus(
        profileID: String,
        status: MatchStatus
    ) async throws
}
