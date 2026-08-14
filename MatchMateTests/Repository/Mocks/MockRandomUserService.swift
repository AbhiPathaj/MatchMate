//
//  MockRandomUserService.swift
//  MatchMate
//
//  Created by Abhishek Pathak on 14/08/26.
//


@testable import MatchMate

final class MockRandomUserService: RandomUserService {

    var result: Result<[Profile], Error>

    init(
        result: Result<[Profile], Error>
    ) {
        self.result = result
    }

    func fetchProfiles(
        page: Int
    ) async throws -> [Profile] {
        try result.get()
    }
}
