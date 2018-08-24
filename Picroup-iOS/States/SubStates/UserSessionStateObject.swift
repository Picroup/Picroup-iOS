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

extension UserSessionStateObject {
    
    static func createValues() -> Any {
        return ["_id": PrimaryKey.default]
    }
}

extension UserSessionStateObject {
    
    enum Event {
        case onCreateUser(UserDetailFragment)
        case onRemoveUser
    }
}

extension UserSessionStateObject: IsFeedbackStateObject {
    func reduce(event: Event, realm: Realm) {
        switch event {
        case .onCreateUser(let data):
            currentUser = UserObject.create(from: data)(realm)
        case .onRemoveUser:
            currentUser = nil
        }
    }
}

