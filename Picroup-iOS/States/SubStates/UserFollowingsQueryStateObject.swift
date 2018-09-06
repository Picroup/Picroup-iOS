//
//  UserFollowingsQueryStateObject.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/30.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RealmSwift

class UserFollowingsQueryStateObject: CursorUserQueryStateObject {
    @objc dynamic var userId: String = ""
}

extension UserFollowingsQueryStateObject {
    func query(currentUserId: String?) -> UserFollowingsQuery? {
        let (byUserId, withFollowed) = currentUserId == nil
            ? ("", false)
            : (currentUserId!, true)
        return trigger
            ? UserFollowingsQuery(userId: userId, followedByUserId: byUserId, cursor: cursorUsers?.cursor.value, withFollowed: withFollowed)
            : nil
    }
}


extension UserFollowingsQueryStateObject {
    
    static func createValues(id: String, userId: String) -> Any {
        return  [
            "_id": id,
            "userId": userId,
            "cursorUsers": ["_id": id],
        ]
    }
}

extension UserFollowingsQueryStateObject {
    
    enum Event {
        case onTriggerReload
        case onTriggerGetMore
        case onGetData(UserFollowingsQuery.Data.User.Following)
        case onGetError(Error)
    }
}

extension UserFollowingsQueryStateObject: IsFeedbackStateObject {
    
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
                cursorUsers = CursorUsersObject.create(from: data, id: PrimaryKey.userFollowingsId(userId))(realm)
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

