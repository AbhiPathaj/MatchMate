//
//  MatchesViewModelTests.swift
//  MatchMate
//
//  Created by Abhishek Pathak on 14/08/26.
//


import XCTest
@testable import MatchMate

@MainActor
final class MatchesViewModelTests: XCTestCase {

    func testFetchProfilesLoadsProfiles() async {

        let profile = makeProfile()

        let repository = MockMatchesRepository()

        repository.fetchResult = .success([
            profile
        ])

        let viewModel = MatchesViewModel(
            repository: repository
        )

        await viewModel.fetchProfiles()

        XCTAssertEqual(
            viewModel.profiles.count,
            1
        )

        XCTAssertEqual(
            viewModel.profiles[0].id,
            profile.id
        )

        XCTAssertFalse(
            viewModel.isLoading
        )

        XCTAssertNil(
            viewModel.error
        )
    }
}