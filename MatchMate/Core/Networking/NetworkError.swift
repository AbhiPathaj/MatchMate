//
//  NetworkError.swift
//  MatchMate
//
//  Created by Abhishek Pathak on 14/08/26.
//


import Foundation

enum NetworkError: Error {
    case invalidResponse
    case httpError(statusCode: Int)
}