//
//  UserFollowersQueryStateObject.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/30.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RealmSwift

class UserFollowersQueryStateObject: CursorUserQueryStateObject {
    @objc dynamic var userId: String = ""
}

extension UserFollowersQueryStateObject {
    func query(currentUserId: String?) -> UserFollowersQuery? {
        let (byUserId, withFollowed) = currentUserId == nil
            ? ("", false)
            : (currentUserId!, true)
        return trigger
            ? UserFollowersQuery(userId: userId, followedByUserId: byUserId, cursor: cursorUsers?.cursor.value, withFollowed: withFollowed)
            : nil
    }
}


extension UserFollowersQueryStateObject {
    
    static func createValues(id: String, userId: String) -> Any {
        return  [
            "_id": id,
            "userId": userId,
            "cursorUsers": ["_id": id],
        ]
    }
}

extension UserFollowersQueryStateObject {
    
    enum Event {
        case onTriggerReload
        case onTriggerGetMore
        case onGetData(UserFollowersQuery.Data.User.Follower)
        case onGetError(Error)
    }
}

extension UserFollowersQueryStateObject: IsFeedbackStateObject {
    
    func reduce(event: Event, realm: Realm) {
        switch event {
        case .onTriggerReload:
            isReload = true
            cursorUsers?.cursor.value = nil
            error = nil
            trigger = true
        case .onTriggerGetMore:
            guard shouldQueryMore else { return }
            isReload = false
            error = nil
            trigger = true
        case .onGetData(let data):
            if isReload {
                cursorUsers = CursorUsersObject.create(from: data, id: PrimaryKey.userFollowersId(userId))(realm)
                isReload = false
            } else {
                cursorUsers?.merge(from: data)(realm)
            }
            error = nil
            trigger = false
        case .onGetError(let error):
            self.error = error.localizedDescription
            trigger = false
        }
    }
}
