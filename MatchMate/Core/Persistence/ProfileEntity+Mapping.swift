//
//  ProfileEntity+Mapping.swift
//  MatchMate
//
//  Created by Abhishek Pathak on 14/08/26.
//

import Foundation

import CoreData

extension ProfileEntity {
    
    func update(
        from profile: Profile,
        updateStatus: Bool = true
    ) {
        id = profile.id
        firstName = profile.firstName
        lastName = profile.lastName
        gender = profile.gender
        email = profile.email
        phone = profile.phone
        city = profile.city
        country = profile.country
        nationality = profile.nationality
        dateOfBirth = profile.dateOfBirth
        registeredDate = profile.registeredDate
        pictureLarge = profile.largeImageURL?.absoluteString
        pictureMedium = profile.mediumImageURL?.absoluteString
        
        if updateStatus {
            matchStatus = profile.matchStatus.rawValue
        }
    }
    
    func toDomain() throws -> Profile {
        
        guard
            let id,
            let firstName,
            let lastName,
            let gender,
            let email,
            let phone,
            let city,
            let country,
            let nationality,
            let pictureLarge,
            let pictureMedium,
            let matchStatus,
            let status = MatchStatus(rawValue: matchStatus)
        else {
            throw PersistenceError.invalidProfileData
        }
        
        return Profile(
            id: id,
            firstName: firstName,
            lastName: lastName,
            gender: gender,
            nationality: nationality,
            city: city,
            country: country,
            email: email,
            phone: phone,
            dateOfBirth: dateOfBirth,
            registeredDate: registeredDate,
            largeImageURL: URL(string: pictureLarge),
            mediumImageURL: URL(string: pictureMedium),
            matchStatus: status
        )
    }
}
