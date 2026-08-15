//
//  DefaultMatchesRepositoryTests.swift
//  MatchMateTests
//
//  Created by Abhishek Pathak on 14/08/26.
//

import Foundation

import XCTest
@testable import MatchMate

final class DefaultMatchesRepositoryTests: XCTestCase {
    
    func testFetchProfilesReturnsRemoteProfilesAndSavesLocally() async throws {
        
        let profile = makeProfile()
        
        let remoteService = MockRandomUserService(
            result: .success([profile])
        )
        
        let localDataSource = MockLocalDataSource()
        
        let repository = DefaultMatchesRepository(
            remoteService: remoteService,
            localDataSource: localDataSource
        )
        
        let profiles = try await repository.fetchProfiles(
            page: 1
        )
        
        XCTAssertEqual(profiles.count, 1)
        XCTAssertEqual(profiles[0].id, profile.id)
        
        XCTAssertEqual(
            localDataSource.savedProfiles.count,
            1
        )
        
        XCTAssertEqual(
            localDataSource.savedProfiles[0].id,
            profile.id
        )
    }
    
    func testFetchProfilesPropagatesRemoteErrorAndDoesNotSave() async {
        
        let networkError = NetworkError.httpError(
            statusCode: 500
        )
        
        let remoteService = MockRandomUserService(
            result: .failure(networkError)
        )
        
        let localDataSource = MockLocalDataSource()
        
        let repository = DefaultMatchesRepository(
            remoteService: remoteService,
            localDataSource: localDataSource
        )
        
        do {
            _ = try await repository.fetchProfiles(page: 1)
            
            XCTFail("Expected fetchProfiles to throw")
            
        } catch let error as NetworkError {
            
            switch error {
                case .httpError(let statusCode):
                    XCTAssertEqual(statusCode, 500)
                    
                default:
                    XCTFail("Unexpected NetworkError")
            }
            
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
        
        XCTAssertTrue(
            localDataSource.savedProfiles.isEmpty
        )
    }
    
    func testFetchProfilesReturnsCachedProfilesWhenRemoteFails() async throws {
        
        let profile = makeProfile(
            status: .accepted
        )
        
        let remoteService = MockRandomUserService(
            result: .failure(
                NetworkError.httpError(statusCode: 500)
            )
        )
        
        let localDataSource = MockLocalDataSource()
        localDataSource.cachedProfiles = [profile]
        
        let repository = DefaultMatchesRepository(
            remoteService: remoteService,
            localDataSource: localDataSource
        )
        
        let profiles = try await repository.fetchProfiles(
            page: 1
        )
        
        XCTAssertEqual(profiles.count, 1)
        XCTAssertEqual(profiles[0].id, profile.id)
        XCTAssertEqual(
            profiles[0].matchStatus,
            .accepted
        )
    }
    
    func testFetchCachedProfilesReturnsLocalProfiles() async throws {
        
        let profile = makeProfile()
        
        let remoteService = MockRandomUserService(
            result: .success([])
        )
        
        let localDataSource = MockLocalDataSource()
        
        localDataSource.cachedProfiles = [profile]
        
        let repository = DefaultMatchesRepository(
            remoteService: remoteService,
            localDataSource: localDataSource
        )
        
        let profiles = try await repository.fetchCachedProfiles()
        
        XCTAssertEqual(profiles.count, 1)
        XCTAssertEqual(profiles[0].id, profile.id)
    }
    
    func testUpdateStatusDelegatesToLocalDataSource() async throws {
        
        let localDataSource = MockLocalDataSource()
        
        let profile = makeProfile(
            id: "profile-1"
        )
        
        localDataSource.cachedProfiles = [
            profile
        ]
        
        let repository = DefaultMatchesRepository(
            remoteService: MockRandomUserService(
                result: .success([])
            ),
            localDataSource: localDataSource
        )
        
        try await repository.updateStatus(
            profileID: "profile-1",
            status: .accepted
        )
        
        XCTAssertEqual(
            localDataSource.updatedProfileID,
            "profile-1"
        )
        
        XCTAssertEqual(
            localDataSource.updatedStatus,
            .accepted
        )
        
        XCTAssertEqual(
            localDataSource.cachedProfiles.first?.matchStatus,
            .accepted
        )
    }
}

private extension DefaultMatchesRepositoryTests {
    
    func makeProfile(
        id: String = "test-user-123",
        status: MatchStatus = .pending
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
            matchStatus: status
        )
    }
}
