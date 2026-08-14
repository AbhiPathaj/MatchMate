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
    
    func testFetchProfilesSetsErrorWhenRepositoryFails() async {
        
        let repository = MockMatchesRepository()
        
        let expectedError = NetworkError.httpError(
            statusCode: 500
        )
        
        repository.fetchResult = .failure(
            expectedError
        )
        
        let viewModel = MatchesViewModel(
            repository: repository
        )
        
        await viewModel.fetchProfiles()
        
        XCTAssertTrue(
            viewModel.profiles.isEmpty
        )
        
        XCTAssertFalse(
            viewModel.isLoading
        )
        
        XCTAssertNotNil(
            viewModel.error
        )
    }
    
    func testAcceptUpdatesProfileStatus() async {
        
        let profile = makeProfile()
        
        let repository = MockMatchesRepository()
        
        repository.fetchResult = .success([
            profile
        ])
        
        let viewModel = MatchesViewModel(
            repository: repository
        )
        
        await viewModel.fetchProfiles()
        
        await viewModel.accept(
            profileID: profile.id
        )
        
        XCTAssertEqual(
            repository.updatedProfileID,
            profile.id
        )
        
        XCTAssertEqual(
            repository.updatedStatus,
            .accepted
        )
        
        XCTAssertEqual(
            viewModel.profiles[0].matchStatus,
            .accepted
        )
    }
    
    func testDeclineUpdatesProfileStatus() async {
        
        let profile = makeProfile()
        
        let repository = MockMatchesRepository()
        
        repository.fetchResult = .success([
            profile
        ])
        
        let viewModel = MatchesViewModel(
            repository: repository
        )
        
        await viewModel.fetchProfiles()
        
        await viewModel.decline(
            profileID: profile.id
        )
        
        XCTAssertEqual(
            repository.updatedProfileID,
            profile.id
        )
        
        XCTAssertEqual(
            repository.updatedStatus,
            .declined
        )
        
        XCTAssertEqual(
            viewModel.profiles[0].matchStatus,
            .declined
        )
    }
    
}

private extension MatchesViewModelTests {
    
    func makeProfile(
        id: String = "test-user-123"
    ) -> Profile {
        
        Profile(
            id: id,
            firstName: "John",
            lastName: "Doe",
            gender: "male",
            nationality: "IN",
            city: "Delhi",
            country: "India",
            email: "john@example.com",
            phone: "9876543210",
            dateOfBirth: Date(),
            registeredDate: Date(),
            largeImageURL: URL(
                string: "https://example.com/large.jpg"
            ),
            mediumImageURL: URL(
                string: "https://example.com/medium.jpg"
            ),
            matchStatus: .pending
        )
    }
}
