//
//  Comment.swift
//  PetSearch
//
//  Created by KK on 2018/5/31.
//  Copyright © 2018 Denis Eltcov. All rights reserved.
//

import Foundation

struct Comment {
    static let TableName = "Comment"
    var UserDisplayName: String
    var UserEmail: String
    var Text: String
    var Date: UInt64
    
    var dictionary: [String: Any] {
        return [
            "UserEmail": UserEmail,
            "UserDisplayName": UserDisplayName,
            "Text": Text,
            "Date": Date
        ]
    }
}

extension Comment: DocumentSerializable {
    init?(dictionary: [String : Any]) {
        guard let userDisplayName = dictionary["UserDisplayName"] as? String,
            let userEmail = dictionary["UserEmail"] as? String,
            let text = dictionary["Text"] as? String,
            let date = dictionary["Date"] as? UInt64 else { return nil }
        
        self.init(
            UserDisplayName: userDisplayName,
            UserEmail: userEmail,
            Text: text,
            Date: date
        )
    }
}
