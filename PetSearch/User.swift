//
//  User.swift
//  PetSearch
//
//  Created by KK on 2018/5/31.
//  Copyright © 2018 Denis Eltcov. All rights reserved.
//

import Foundation

struct User {
    static let TableName = "User"
    var Uid: String
    var Email: String
    var Username: String
    var Phone: String
    
    var dictionary: [String: Any] {
        return [
            "Uid": Uid,
            "Email": Email,
            "Username": Username,
            "Phone": Phone
        ]
    }
}

extension User: DocumentSerializable {
    init?(dictionary: [String : Any]) {
        guard let uid = dictionary["Uid"] as? String,
            let email = dictionary["Email"] as? String,
            let username = dictionary["Username"] as? String,
            let phone = dictionary["Phone"] as? String else { return nil }
        
        self.init(Uid: uid,
                  Email: email,
                  Username: username,
                  Phone: phone)
    }
}
