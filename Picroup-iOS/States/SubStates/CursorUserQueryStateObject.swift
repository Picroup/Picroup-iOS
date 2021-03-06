//
//  CursorUserQueryStateObject.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/30.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RealmSwift

class CursorUserQueryStateObject: PrimaryObject {
    
    @objc dynamic var cursorUsers: CursorUsersObject?
    @objc dynamic var error: String?
    @objc dynamic var isReload: Bool = false
    @objc dynamic var trigger: Bool = false
}

extension CursorUserQueryStateObject {
    func userFollowingsQuery(userId: String, currentUserId: String?) -> UserFollowingsQuery? {
        let (byUserId, withFollowed) = currentUserId == nil
            ? ("", false)
            : (currentUserId!, true)
        return trigger
            ? UserFollowingsQuery(userId: userId, followedByUserId: byUserId, cursor: cursorUsers?.cursor.value, withFollowed: withFollowed)
            : nil
    }
    func userFollowersQuery(userId: String, currentUserId: String?) -> UserFollowersQuery? {
        let (byUserId, withFollowed) = currentUserId == nil
            ? ("", false)
            : (currentUserId!, true)
        return trigger
            ? UserFollowersQuery(userId: userId, followedByUserId: byUserId, cursor: cursorUsers?.cursor.value, withFollowed: withFollowed)
            : nil
    }
}

extension CursorUserQueryStateObject {
    var hasMore: Bool {
        return cursorUsers?.cursor.value != nil
    }
    var shouldQueryMore: Bool {
        return !trigger && hasMore
    }
    var isEmpty: Bool {
        guard let items = cursorUsers?.items else { return false }
        return trigger == false && error == nil && items.isEmpty
    }
}
