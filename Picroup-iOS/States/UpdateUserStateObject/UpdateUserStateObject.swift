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

final class UpdateUserStateObject: PrimaryObject {
    
    typealias SetImageKeyQuery = (userId: String, imageKey: String)
    
    @objc dynamic var sessionState: UserSessionStateObject?
    
    @objc dynamic var imageKey: String?
    @objc dynamic var setAvatarIdError: String?
    @objc dynamic var triggerSetAvatarIdQuery: Bool = false
    
    @objc dynamic var displayName: String = ""
    @objc dynamic var setDisplayNameError: String?
    @objc dynamic var triggerSetDisplayNameQuery: Bool = false

    @objc dynamic var routeState: RouteStateObject?
}

extension UpdateUserStateObject {
    var setImageKeyQuery: SetImageKeyQuery? {
        guard let userId = sessionState?.currentUserId,
            let imageKey = imageKey
            else { return nil }
        let next = (userId, imageKey)
        return triggerSetAvatarIdQuery ? next : nil
    }
    var setDisplayNameQuery: UserSetDisplayNameQuery? {
        guard let userId = sessionState?.currentUserId else { return nil }
        let next = UserSetDisplayNameQuery(userId: userId, displayName: displayName)
        return triggerSetDisplayNameQuery ? next : nil
    }
    var shouldSetDisplay: Bool {
        return displayName.matchExpression(RegularPattern.displayName)
    }
}

extension UpdateUserStateObject {
    
    static func create() -> (Realm) throws -> UpdateUserStateObject {
        return { realm in
            let _id = PrimaryKey.default
            let value: Any = [
                "_id": _id,
                "sessionState": UserSessionStateObject.createValues(),
                "routeState": RouteStateObject.createValues(),
                ]
            let result = try realm.update(UpdateUserStateObject.self, value: value)
            try realm.write {
                result.imageKey = nil
                result.displayName = result.sessionState?.currentUser?.displayName ?? ""
            }
            return result
        }
    }
}
