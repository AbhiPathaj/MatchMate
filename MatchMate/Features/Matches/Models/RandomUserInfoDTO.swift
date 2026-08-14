//
//  RandomUserInfoDTO.swift
//  MatchMate
//
//  Created by Abhishek Pathak on 14/08/26.
//


nonisolated struct RandomUserInfoDTO: Decodable {
    let seed: String
    let results: Int
    let page: Int
    let version: String
}
