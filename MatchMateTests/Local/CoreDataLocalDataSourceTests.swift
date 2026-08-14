//
//  CoreDataLocalDataSourceTests.swift
//  MatchMate
//
//  Created by Abhishek Pathak on 14/08/26.
//


import XCTest
import CoreData
@testable import MatchMate

final class CoreDataLocalDataSourceTests: XCTestCase {
    
    private var persistenceController: PersistenceController!
    private var dataSource: CoreDataLocalDataSource!
    
    override func setUp() {
        super.setUp()
        
        persistenceController = PersistenceController(
            inMemory: true
        )
        
        dataSource = CoreDataLocalDataSource(
            context: persistenceController.container.viewContext
        )
    }
    
    override func tearDown() {
        dataSource = nil
        persistenceController = nil
        
        super.tearDown()
    }
    
    func testSaveProfilesAndFetchProfiles() async throws {
        
        let profile = makeProfile()
        
        try await dataSource.saveProfiles([profile])
        
        let profiles = try await dataSource.fetchProfiles()
        
        XCTAssertEqual(profiles.count, 1)
        XCTAssertEqual(profiles[0].id, profile.id)
        XCTAssertEqual(profiles[0].firstName, "John")
        XCTAssertEqual(profiles[0].lastName, "Doe")
        XCTAssertEqual(profiles[0].matchStatus, .pending)
    }
    func testUpdateStatusPersistsAcceptedStatus() async throws {
        
        let profile = makeProfile()
        
        try await dataSource.saveProfiles([profile])
        
        try await dataSource.updateStatus(
            profileID: profile.id,
            status: .accepted
        )
        
        let profiles = try await dataSource.fetchProfiles()
        
        XCTAssertEqual(profiles.count, 1)
        XCTAssertEqual(profiles[0].matchStatus, .accepted)
    }
    func testUpdateStatusPersistsDeclinedStatus() async throws {
        
        let profile = makeProfile()
        
        try await dataSource.saveProfiles([profile])
        
        try await dataSource.updateStatus(
            profileID: profile.id,
            status: .declined
        )
        
        let profiles = try await dataSource.fetchProfiles()
        
        XCTAssertEqual(profiles[0].matchStatus, .declined)
    }
    
    func testSavingExistingProfileDoesNotOverwriteLocalStatus() async throws {
        
        let profile = makeProfile(
            status: .pending
        )
        
        try await dataSource.saveProfiles([profile])
        
        // User accepts the profile.
        try await dataSource.updateStatus(
            profileID: profile.id,
            status: .accepted
        )
        
        // API refreshes the same profile and says pending.
        let refreshedProfile = makeProfile(
            status: .pending
        )
        
        try await dataSource.saveProfiles([
            refreshedProfile
        ])
        
        // Fetch AFTER all mutations.
        let profiles = try await dataSource.fetchProfiles()
        
        XCTAssertEqual(profiles.count, 1)
        XCTAssertEqual(profiles[0].id, profile.id)
        XCTAssertEqual(profiles[0].matchStatus, .accepted)
    }
    
    func testUpdateStatusThrowsWhenProfileDoesNotExist() async {
        
        do {
            try await dataSource.updateStatus(
                profileID: "does-not-exist",
                status: .accepted
            )
            
            XCTFail("Expected profileNotFound error")
            
        } catch let error as PersistenceError {
            
            guard case .profileNotFound = error else {
                XCTFail("Unexpected persistence error")
                return
            }
            
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testSavingSameProfileTwiceDoesNotCreateDuplicate() async throws {
        
        let profile = makeProfile()
        
        try await dataSource.saveProfiles([profile])
        try await dataSource.saveProfiles([profile])
        
        let profiles = try await dataSource.fetchProfiles()
        
        XCTAssertEqual(profiles.count, 1)
        XCTAssertEqual(profiles[0].id, profile.id)
    }
    
}
private extension CoreDataLocalDataSourceTests {
    
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
