//
//  MatchesViewModel.swift
//  MatchMate
//
//  Created by Abhishek Pathak on 14/08/26.
//


import Foundation
import Observation

@MainActor
@Observable
final class MatchesViewModel {

    private let repository: MatchesRepository

    private(set) var profiles: [Profile] = []
    private(set) var isLoading = false
    private(set) var error: Error?

    private var currentPage = 1

    init(repository: MatchesRepository) {
        self.repository = repository
    }

    func fetchProfiles() async {
        guard !isLoading else { return }

        isLoading = true
        error = nil

        defer {
            isLoading = false
        }

        do {
            let fetchedProfiles = try await repository.fetchProfiles(
                page: currentPage
            )

            profiles.append(contentsOf: fetchedProfiles)
            currentPage += 1

        } catch {
            self.error = error
        }
    }

    func accept(profileID: String) async {
        await updateStatus(
            profileID: profileID,
            status: .accepted
        )
    }

    func decline(profileID: String) async {
        await updateStatus(
            profileID: profileID,
            status: .declined
        )
    }

    private func updateStatus(
        profileID: String,
        status: MatchStatus
    ) async {
        do {
            try await repository.updateStatus(
                profileID: profileID,
                status: status
            )

            if let index = profiles.firstIndex(
                where: { $0.id == profileID }
            ) {
                profiles[index].matchStatus = status
            }

        } catch {
            self.error = error
        }
    }
}
