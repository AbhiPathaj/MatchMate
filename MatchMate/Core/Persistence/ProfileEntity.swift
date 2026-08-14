//
//  ProfileEntity.swift
//  MatchMate
//
//  Created by Abhishek Pathak on 14/08/26.
//


import CoreData

@objc(ProfileEntity)
final class ProfileEntity: NSManagedObject {

}
extension ProfileEntity {
    
    @nonobjc
    class func fetchRequest() -> NSFetchRequest<ProfileEntity> {
        NSFetchRequest<ProfileEntity>(
            entityName: "ProfileEntity"
        )
    }
}

extension ProfileEntity {
    
    @NSManaged var id: String?
    @NSManaged var firstName: String?
    @NSManaged var lastName: String?
    @NSManaged var gender: String?
    @NSManaged var email: String?
    @NSManaged var phone: String?
    @NSManaged var city: String?
    @NSManaged var country: String?
    @NSManaged var nationality: String?
    @NSManaged var dateOfBirth: Date?
    @NSManaged var age: Int16
    @NSManaged var registeredDate: Date?
    @NSManaged var pictureLarge: String?
    @NSManaged var pictureMedium: String?
    @NSManaged var matchStatus: String?
}
