//
//  Pet.swift
//  PetSearch
//
//  Created by KK on 2018/5/31.
//  Copyright © 2018 Denis Eltcov. All rights reserved.
//

import Foundation

struct Pet {
    static let TableName = "Pet"
    var PetId: String
    var Uid: String
    var Name: String
    var Breed: String
    var Color: String
    var Age: Int
    var MicrochipNumber: String
    var Photo: String
    var Size: String
    var Kind: String
    var Gender: String
    var Desexed: String
    var Status: String
    var MissingSince: UInt64
    var Description: String
    var Latitude: Double
    var Longitude: Double
    var Region: String
    
    var dictionary: [String: Any] {
        return [
            "PetId": PetId,
            "Uid": Uid,
            "Name": Name,
            "Breed": Breed,
            "Color": Color,
            "Age": Age,
            "MicrochipNumber": MicrochipNumber,
            "Photo": Photo,
            "Size": Size,
            "Kind": Kind,
            "Gender": Gender,
            "Desexed": Desexed,
            "Status": Status,
            "MissingSince": MissingSince,
            "Description": Description,
            "Latitude": Latitude,
            "Longitude": Longitude,
            "Region": Region
        ]
    }
}

extension Pet: DocumentSerializable {
    
    static let sizes = ["Small", "Medium", "Big"]
    
    static let kinds = ["Dog", "Cat", "Other"]
    
    static let genders = ["Male", "Female"]
    
    static let desexeds = ["Yes", "No"]
    
    static let status = ["Lost", "Found"]
    
    init?(dictionary: [String: Any]) {
        guard let petId = dictionary["PetId"] as? String,
            let uid = dictionary["Uid"] as? String,
            let size = dictionary["Size"] as? String,
            let kind = dictionary["Kind"] as? String,
            let status = dictionary["Status"] as? String,
            let photo = dictionary["Photo"] as? String
            else { return nil }
        
        self.init(PetId: petId,
                  Uid: uid,
                  Name: dictionary["Name"] as? String ?? "",
                  Breed: dictionary["Breed"] as? String ?? "",
                  Color: dictionary["Color"] as? String ?? "",
                  Age: dictionary["Age"] as? Int ?? 0,
                  MicrochipNumber: dictionary["MicrochipNumber"] as? String ?? "",
                  Photo: photo,
                  Size: size,
                  Kind: kind,
                  Gender: dictionary["Gender"] as? String ?? "",
                  Desexed: dictionary["Desexed"] as? String ?? "",
                  Status: status,
                  MissingSince: dictionary["MissingSince"] as? UInt64 ?? Date().timestamp,
                  Description: dictionary["Description"] as? String ?? "",
                  Latitude: dictionary["Latitude"] as? Double ?? 0.00,
                  Longitude: dictionary["Longitude"] as? Double ?? 0.00,
                  Region: dictionary["Region"] as? String ?? "")
    }
}
