//
//  Profile.swift
//  MatchMate
//
//  Created by Abhishek Pathak on 14/08/26.
//


import Foundation

nonisolated struct Profile: Identifiable {
    let id: String
    let firstName: String
    let lastName: String
    let gender: String
    let nationality: String
    let city: String
    let country: String
    let email: String
    let phone: String
    let dateOfBirth: Date?
    let registeredDate: Date?
    let largeImageURL: URL?
    let mediumImageURL: URL?
    var matchStatus: MatchStatus
}

extension Profile {
    init(dto: RandomUserProfileDTO) {
        self.id = dto.login.uuid
        self.firstName = dto.name.first
        self.lastName = dto.name.last
        self.gender = dto.gender
        self.nationality = dto.nat
        self.city = dto.location.city
        self.country = dto.location.country
        self.email = dto.email
        self.phone = dto.phone
        self.largeImageURL = URL(string: dto.picture.large)
        self.mediumImageURL = URL(string: dto.picture.medium)
        self.dateOfBirth = Self.parseDate(dto.dob.date)
        self.registeredDate = Self.parseDate(dto.registered.date)
        self.matchStatus = .pending
    }
}

private extension Profile {
    static func parseDate(_ value: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [
            .withInternetDateTime,
            .withFractionalSeconds
        ]
        
        return formatter.date(from: value)
    }
}
