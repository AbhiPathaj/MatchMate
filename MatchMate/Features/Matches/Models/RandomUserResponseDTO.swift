//
//  RandomUserResponseDTO.swift
//  MatchMate
//
//  Created by Abhishek Pathak on 14/08/26.
//


nonisolated struct RandomUserResponseDTO: Decodable {
    let results: [RandomUserProfileDTO]
    let info: RandomUserInfoDTO
}
/*
name
├── title
├── first
└── last

picture
├── large
└── medium

login
└── uuid
*/
