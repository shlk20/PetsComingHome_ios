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
    var Age: String
    var MicrochipNumber: String
    var Photo: String
    var Size: String
    var Kind: String
    var Gender: String
    var Desexed: String
    var Status: String
    var MissingSince: String
    var Description: String
    var LastX: Double
    var LastY: Double
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
            "LastX": LastX,
            "LastY": LastY,
            "Region": Region
        ]
    }
}

extension Pet: DocumentSerializable {
    
    init?(dictionary: [String: Any]) {
        guard let petId = dictionary["PetId"] as? String,
            let uid = dictionary["Uid"] as? String,
            let name = dictionary["Name"] as? String,
            let breed = dictionary["Breed"] as? String,
            let color = dictionary["Color"] as? String,
            let age = dictionary["Age"] as? String,
            let microchipNumber = dictionary["MicrochipNumber"] as? String,
            let photo = dictionary["Photo"] as? String  else { return nil }
        
        self.init(PetId: petId,
                  Uid: uid,
                  Name: name,
                  Breed: breed,
                  Color: color,
                  Age: age,
                  MicrochipNumber: microchipNumber,
                  Photo: photo,
                  Size: dictionary["Size"] as? String ?? "",
                  Kind: dictionary["Kind"] as? String ?? "",
                  Gender: dictionary["Gender"] as? String ?? "",
                  Desexed: dictionary["Desexed"] as? String ?? "",
                  Status: dictionary["Status"] as? String ?? "",
                  MissingSince: dictionary["MissingSince"] as? String ?? "",
                  Description: dictionary["Description"] as? String ?? "",
                  LastX: dictionary["LastX"] as? Double ?? 0.00,
                  LastY: dictionary["LastY"] as? Double ?? 0.00,
                  Region: dictionary["Region"] as? String ?? "")
    }
}
