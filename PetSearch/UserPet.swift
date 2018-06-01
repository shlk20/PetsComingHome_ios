//
//  UserPet.swift
//  PetSearch
//
//  Created by KK on 2018/5/31.
//  Copyright © 2018 Denis Eltcov. All rights reserved.
//

import Foundation

struct UserPet {
    static let TableName = "UserPet"
    var Uid: String
    var PetId: String
    var WasViewed: String
    
    var dictionary: [String: Any] {
        return [
            "Uid": Uid,
            "PetId": PetId,
            "WasViewed": WasViewed
        ]
    }
}

extension UserPet: DocumentSerializable {
    init?(dictionary: [String : Any]) {
         guard let uid = dictionary["Uid"] as? String,
            let petId = dictionary["PetId"] as? String,
            let wasViewed = dictionary["WasViewed"] as? String else { return nil }
        
        self.init(
            Uid: uid,
            PetId: petId,
            WasViewed: wasViewed
        )
    }
}
