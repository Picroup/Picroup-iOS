//
//  UserObject.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/14.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift
import Apollo

final class UserObject: PrimaryObject {
    @objc dynamic var username: String?
    @objc dynamic var avatarId: String?
    let followingsCount = RealmOptional<Int>()
    let followersCount = RealmOptional<Int>()
    let reputation = RealmOptional<Int>()
    let gainedReputation = RealmOptional<Int>()
    let notificationsCount = RealmOptional<Int>()
    let followed = RealmOptional<Bool>()
}

extension UserObject {
    
    static func create(from fragment: UserFragment) -> (Realm) -> UserObject {
        return { realm in realm.create(UserObject.self, value: fragment.snapshot, update: true) }
    }
    
    static func create(from fragment: UserDetailFragment) -> (Realm) -> UserObject {
        return { realm in realm.create(UserObject.self, value: fragment.snapshot, update: true) }
    }
}

final class CursorUsersObject: PrimaryObject {
    
    let cursor = RealmOptional<Double>()
    let items = List<UserObject>()
}


extension CursorUsersObject {
    
    static func create(from data: UserFollowingsQuery.Data.User.Following, id: String) -> (Realm) -> CursorUsersObject {
        return { realm in
            let value: Snapshot = data.snapshot.merging(["_id": id]) { $1 }
            return realm.create(CursorUsersObject.self, value: value, update: true)
        }
    }
    
    func merge(from data: UserFollowingsQuery.Data.User.Following) -> (Realm) -> Void {
        return { realm in
            let items = data.items.map { realm.create(UserObject.self, value: $0.snapshot, update: true) }
            self.cursor.value = data.cursor
            self.items.append(objectsIn: items)
        }
    }
}


extension CursorUsersObject {
    
    static func create(from data: UserFollowersQuery.Data.User.Follower, id: String) -> (Realm) -> CursorUsersObject {
        return { realm in
            let value: Snapshot = data.snapshot.merging(["_id": id]) { $1 }
            return realm.create(CursorUsersObject.self, value: value, update: true)
        }
    }
    
    func merge(from data: UserFollowersQuery.Data.User.Follower) -> (Realm) -> Void {
        return { realm in
            let items = data.items.map { realm.create(UserObject.self, value: $0.snapshot, update: true) }
            self.cursor.value = data.cursor
            self.items.append(objectsIn: items)
        }
    }
}
