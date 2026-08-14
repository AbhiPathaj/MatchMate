//
//  NetworkError.swift
//  MatchMate
//
//  Created by Abhishek Pathak on 14/08/26.
//


import Foundation

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
}
