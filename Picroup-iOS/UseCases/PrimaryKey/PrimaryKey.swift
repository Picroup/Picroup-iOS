//
//  PrimaryKey.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/18.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation

struct PrimaryKey {
    static let `default` = "default"
//    static let rankMediaId = "currentDevice.rankMedia"
    static let hotMediaId = "currentDevice.hotMedia"
    static let myMediaId = "currentUser.myMedia"
    static let myStaredMediaId = "currentUser.myStaredMedia"
    static let myInterestedMediaId = "currentUser.myInterestedMediaId"

    static func recommendMediaId(_ mediumId: String) -> String {
        return "medium.\(mediumId).recommendMedia"
    }
    
    static func commentsId(_ mediumId: String) -> String {
        return "medium.\(mediumId).comments"
    }
    
    static func userMediaId(_ userId: String) -> String {
        return "user.\(userId).userMedia"
    }
    
    static func userFollowingsId(_ userId: String) -> String {
        return "user.\(userId).userFollowings"
    }
    
    static func userFollowersId(_ userId: String) -> String {
        return "user.\(userId).userFollowers"
    }
    
    static func feedbackId(kind: String?, toUserId: String?, mediumId: String?, commentId: String?) -> String {
        switch (kind, toUserId, mediumId, commentId) {
        case (FeedbackKind.app.rawValue?, _, _, _):
            return "\(kind!)"
        case (FeedbackKind.user.rawValue?, let toUserId?, _, _):
            return "\(kind!).\(toUserId)"
        case (FeedbackKind.medium.rawValue?, _, let mediumId?, _):
            return "\(kind!).\(mediumId)"
        case (FeedbackKind.comment.rawValue?, _, _, let commentId?):
            return "\(kind!).\(commentId)"
        default:
            return UUID().uuidString
        }
    }
}
