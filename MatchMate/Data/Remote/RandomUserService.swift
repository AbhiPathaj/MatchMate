//
//  RandomUserService.swift
//  MatchMate
//
//  Created by Abhishek Pathak on 14/08/26.
//

import Foundation

import Foundation

protocol RandomUserService {
    func fetchProfiles(page: Int) async throws -> [Profile]
}

nonisolated final class DefaultRandomUserService: RandomUserService {
    
    private let networkClient: NetworkClient
    private let decoder: JSONDecoder
    
    init(
        networkClient: NetworkClient,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.networkClient = networkClient
        self.decoder = decoder
    }
    
    func fetchProfiles(page: Int) async throws -> [Profile] {
        let request = try makeRequest(page: page)
        
        let data = try await networkClient.request(request)
        
        let response = try decoder.decode(
            RandomUserResponseDTO.self,
            from: data
        )
        return response.results.map(Profile.init(dto:))
    }
}

private extension DefaultRandomUserService {
    
    func makeRequest(page: Int) throws -> URLRequest {
        var components = URLComponents(
            string: "https://randomuser.me/api/"
        )
        
        components?.queryItems = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "results", value: "10"),
            URLQueryItem(name: "seed", value: "matchmate")
        ]
        
        guard let url = components?.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(
            "application/json",
            forHTTPHeaderField: "Accept"
        )
        
        return request
    }
}
