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
    static let rankMediaId = "currentDevice.rankMedia"
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
}
