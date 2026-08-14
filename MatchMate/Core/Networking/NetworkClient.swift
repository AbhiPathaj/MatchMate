//
//  NetworkClient.swift
//  MatchMate
//
//  Created by Abhishek Pathak on 14/08/26.
//


import Foundation

protocol NetworkClient {
    func request(_ request: URLRequest) async throws -> Data
}

nonisolated final class URLSessionNetworkClient: NetworkClient {
    
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func request(_ request: URLRequest) async throws -> Data {
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(
                statusCode: httpResponse.statusCode
            )
        }
        
        return data
    }
}
