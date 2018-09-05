//
//  UpdateUserStateObject.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/6/4.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift
import RxCocoa
import RxRealm
import RxAlamofire

final class UpdateUserStateObject: VersionedPrimaryObject {
    
    @objc dynamic var sessionState: UserSessionStateObject?
    @objc dynamic var setAvatarQueryState: UserSetAvatarQueryStateObject?
    @objc dynamic var setDisplayNameQueryState: UserSetDisplayNameQueryStateObject?

    @objc dynamic var routeState: RouteStateObject?
}

extension UpdateUserStateObject {
    var setAvatarQuery: UserSetAvatarQueryStateObject.Query? {
        return setAvatarQueryState?.query(userId: sessionState?.currentUserId)
    }
    var setDisplayNameQuery: UserSetDisplayNameQuery? {
        return setDisplayNameQueryState?.query(userId: sessionState?.currentUserId)
    }
}

extension UpdateUserStateObject {
    
    static func create() -> (Realm) throws -> UpdateUserStateObject {
        return { realm in
            let _id = PrimaryKey.default
            let value: Any = [
                "_id": _id,
                "sessionState": UserSessionStateObject.createValues(),
                "setAvatarQueryState": UserSetAvatarQueryStateObject.createValues(),
                "setDisplayNameQueryState": UserSetDisplayNameQueryStateObject.createValues(),
                "routeState": RouteStateObject.createValues(),
                ]
            return try realm.update(UpdateUserStateObject.self, value: value)
        }
    }
}

