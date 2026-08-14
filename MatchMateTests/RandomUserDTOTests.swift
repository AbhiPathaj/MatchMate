//
//  RandomUserDTOTests.swift
//  MatchMate
//
//  Created by Abhishek Pathak on 14/08/26.
//


import XCTest
@testable import MatchMate

final class RandomUserDTOTests: XCTestCase {
    func testDecodeRandomUserResponse() throws {
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
        
        let response = try JSONDecoder().decode(
            RandomUserResponseDTO.self,
            from: data
        )
        
        XCTAssertEqual(response.results.count, 1)
        XCTAssertEqual(response.info.page, 1)
        XCTAssertEqual(response.info.seed, "matchmate")
        
        let user = response.results[0]
        
        XCTAssertEqual(user.login.uuid, "test-user-123")
        XCTAssertEqual(user.name.first, "John")
        XCTAssertEqual(user.name.last, "Doe")
        XCTAssertEqual(user.nat, "IN")
    }
    func testMapDTOToProfile() throws {
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
        
        let response = try JSONDecoder().decode(
            RandomUserResponseDTO.self,
            from: data
        )
        
        let dto = response.results[0]
        
        let profile = Profile(dto: dto)
        
        XCTAssertEqual(profile.id, "test-user-123")
        XCTAssertEqual(profile.firstName, "John")
        XCTAssertEqual(profile.lastName, "Doe")
        XCTAssertEqual(profile.nationality, "IN")
        XCTAssertEqual(profile.city, "Delhi")
        XCTAssertEqual(profile.country, "India")
        XCTAssertEqual(profile.matchStatus, .pending)
        XCTAssertEqual(
            profile.largeImageURL?.absoluteString,
            "https://example.com/large.jpg"
        )
        
        XCTAssertEqual(
            profile.mediumImageURL?.absoluteString,
            "https://example.com/medium.jpg"
        )
        XCTAssertNotNil(profile.dateOfBirth)
        XCTAssertNotNil(profile.registeredDate)
    }
}
