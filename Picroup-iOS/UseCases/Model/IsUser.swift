//
//  IsUser.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/3.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation

protocol IsPreviewUser: HasSnapshot {
    var id: String { get }
    var username: String { get }
    var avatarId: String? { get }
}

protocol IsUser: IsPreviewUser {
    var followingsCount: Int { get }
    var followersCount: Int { get }
    var reputation: Int { get }
    var gainedReputation: Int { get }
    var notificationsCount: Int { get }
}

