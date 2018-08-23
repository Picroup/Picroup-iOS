//
//  RegisterUsernameStateObject.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/6/6.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift
import RxSwift
import RxCocoa


final class RegisterUsernameStateObject: PrimaryObject {
    
    @objc dynamic var registerParam: RegisterParamObject?
    @objc dynamic var isUsernameAvaliable: Bool = false
    @objc dynamic var triggerValidUsernameQuery: Bool = false
}

extension RegisterUsernameStateObject {
    var usernameAvailableQuery: UsernameAvailableQuery? {
        guard let username = registerParam?.username, !username.isEmpty else {
            return nil
        }
        let next = UsernameAvailableQuery(username: username)
        return triggerValidUsernameQuery ? next : nil
    }
    var shouldValidUsername: Bool {
        guard let username = registerParam?.username else { return false }
        return username.matchExpression(RegularPattern.username) 
    }
}

extension RegisterUsernameStateObject {
    
    static func create() -> (Realm) throws -> RegisterUsernameStateObject {
        return { realm in
            let _id = PrimaryKey.default
            let value: Any = [
                "_id": _id,
                "registerParam": ["_id": _id],
                "isUsernameAvaliable": false,
                ]
            return try realm.update(RegisterUsernameStateObject.self, value: value)
        }
    }
}

extension UsernameAvailableQuery: Equatable {
    public static func ==(lhs: UsernameAvailableQuery, rhs: UsernameAvailableQuery) -> Bool {
        return lhs.username == rhs.username
    }
}

