//
//  RandomUserProfileDTO.swift
//  MatchMate
//
//  Created by Abhishek Pathak on 14/08/26.
//


nonisolated struct RandomUserProfileDTO: Decodable {
    let gender: String
    let name: NameDTO
    let location: LocationDTO
    let email: String
    let phone: String
    let login: LoginDTO
    let dob: DateOfBirthDTO
    let registered: RegisteredDTO
    let picture: PictureDTO
    let nat: String
}

nonisolated struct NameDTO: Decodable {
    let title: String
    let first: String
    let last: String
}

nonisolated struct LocationDTO: Decodable {
    let city: String
    let country: String
}
nonisolated struct LoginDTO: Decodable {
    let uuid: String
}
nonisolated struct DateOfBirthDTO: Decodable {
    let date: String
    let age: Int
}

nonisolated struct RegisteredDTO: Decodable {
    let date: String
    let age: Int
}
nonisolated struct PictureDTO: Decodable {
    let large: String
    let medium: String
}
