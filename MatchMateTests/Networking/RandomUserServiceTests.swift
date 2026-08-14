//
//  RandomUserServiceTests.swift
//  MatchMate
//
//  Created by Abhishek Pathak on 14/08/26.
//


import XCTest
@testable import MatchMate

final class RandomUserServiceTests: XCTestCase {

    func testFetchProfilesReturnsProfiles() async throws {

        let json = """
        {
            "results": [
                {
                    "gender": "male",
                    "name": {
                        "title": "Mr",
                        "first": "John",
                        "last": "Doe"
                    },
                    "location": {
                        "city": "Delhi",
                        "country": "India"
                    },
                    "email": "john.doe@example.com",
                    "phone": "9876543210",
                    "login": {
                        "uuid": "test-user-123"
                    },
                    "dob": {
                        "date": "1995-05-15T10:20:30.000Z",
                        "age": 31
                    },
                    "registered": {
                        "date": "2015-05-15T10:20:30.000Z",
                        "age": 11
                    },
                    "picture": {
                        "large": "https://example.com/large.jpg",
                        "medium": "https://example.com/medium.jpg"
                    },
                    "nat": "IN"
                }
            ],
            "info": {
                "seed": "matchmate",
                "results": 1,
                "page": 1,
                "version": "1.4"
            }
        }
        """

        let data = Data(json.utf8)

        let networkClient = MockNetworkClient(
            result: .success(data)
        )

        let service = DefaultRandomUserService(
            networkClient: networkClient
        )

        let profiles = try await service.fetchProfiles(page: 1)

        XCTAssertEqual(profiles.count, 1)
        XCTAssertEqual(profiles[0].id, "test-user-123")
        XCTAssertEqual(profiles[0].firstName, "John")
        XCTAssertEqual(profiles[0].lastName, "Doe")
        XCTAssertEqual(profiles[0].city, "Delhi")
    }
    func testFetchProfilesPropagatesNetworkError() async {
        
        let networkError = NetworkError.httpError(
            statusCode: 500
        )
        
        let networkClient = MockNetworkClient(
            result: .failure(networkError)
        )
        
        let service = DefaultRandomUserService(
            networkClient: networkClient
        )
        
        do {
            _ = try await service.fetchProfiles(page: 1)
            XCTFail("Expected request to throw")
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
    }
    
    func testFetchProfilesThrowsForInvalidJSON() async {
        
        let invalidData = Data("not valid json".utf8)
        
        let networkClient = MockNetworkClient(
            result: .success(invalidData)
        )
        
        let service = DefaultRandomUserService(
            networkClient: networkClient
        )
        
        do {
            _ = try await service.fetchProfiles(page: 1)
            XCTFail("Expected decoding to fail")
        } catch {
            XCTAssertTrue(error is DecodingError)
        }
    }
    func testFetchProfilesBuildsCorrectRequest() async throws {
        
        let networkClient = MockNetworkClient(
            result: .success(Data())
        )
        
        let service = DefaultRandomUserService(
            networkClient: networkClient
        )
        
        do {
            _ = try await service.fetchProfiles(page: 3)
        } catch {
            // Decoding will fail because Data() isn't valid JSON.
            // That's okay for this test because we're interested
            // in the request that was sent.
        }
        
        let request = try XCTUnwrap(
            networkClient.receivedRequest
        )
        
        let components = try XCTUnwrap(
            URLComponents(
                url: try XCTUnwrap(request.url),
                resolvingAgainstBaseURL: false
            )
        )
        
        let queryItems = try XCTUnwrap(
            components.queryItems
        )
        
        XCTAssertEqual(
            queryItems.first(where: { $0.name == "page" })?.value,
            "3"
        )
        
        XCTAssertEqual(
            queryItems.first(where: { $0.name == "results" })?.value,
            "10"
        )
        
        XCTAssertEqual(
            queryItems.first(where: { $0.name == "seed" })?.value,
            "matchmate"
        )
        
        XCTAssertEqual(request.httpMethod, "GET")
    }
}


final class MockNetworkClient: NetworkClient {
    
    let result: Result<Data, Error>
    
    private(set) var receivedRequest: URLRequest?
    
    init(result: Result<Data, Error>) {
        self.result = result
    }
    
    func request(_ request: URLRequest) async throws -> Data {
        
        receivedRequest = request
        
        return try result.get()
    }
}
