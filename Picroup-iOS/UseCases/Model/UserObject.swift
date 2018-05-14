//
//  UserObject.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/14.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift

class UserObject: PrimaryObject {
    @objc dynamic var username: String?
    @objc dynamic var avatarId: String?
    let followingsCount = RealmOptional<Int>()
    let followersCount = RealmOptional<Int>()
    let reputation = RealmOptional<Int>()
    let gainedReputation = RealmOptional<Int>()
    let notificationsCount = RealmOptional<Int>()
}
