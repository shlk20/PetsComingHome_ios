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
    var CommentId: String
    var ParentCommentId: String
    var Uid: String
    var Username: String
    var PetId: String
    var Text: String
    var Date: String
    
    var dictionary: [String: Any] {
        return [
            "CommentId": CommentId,
            "ParentCommentId": ParentCommentId,
            "Uid": Uid,
            "Username": Username,
            "PetId": PetId,
            "Text": Text,
            "Date": Date
        ]
    }
}

extension Comment: DocumentSerializable {
    init?(dictionary: [String : Any]) {
        guard let commentId = dictionary["CommentId"] as? String,
            let parentCommentId = dictionary["ParentCommentId"] as? String,
            let uid = dictionary["Uid"] as? String,
            let username = dictionary["Username"] as? String,
            let petId = dictionary["PetId"] as? String,
            let text = dictionary["Text"] as? String,
            let date = dictionary["Date"] as? String else { return nil }
        
        self.init(
            CommentId: commentId,
            ParentCommentId: parentCommentId,
            Uid: uid,
            Username: username,
            PetId: petId,
            Text: text,
            Date: date
        )
    }
}
