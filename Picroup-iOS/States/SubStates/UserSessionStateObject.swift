//
//  UserSessionStateObject.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/23.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift

final class UserSessionStateObject: PrimaryObject {
    @objc dynamic var currentUser: UserObject?
}

extension UserSessionStateObject {
    var isLogin: Bool {
        return currentUser != nil
    }
    var currentUserId: String? {
        return currentUser?._id
    }
}
