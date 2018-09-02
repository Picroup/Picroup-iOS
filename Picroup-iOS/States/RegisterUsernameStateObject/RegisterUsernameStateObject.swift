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

final class RegisterUsernameStateObject: VersionedPrimaryObject {
    
    @objc dynamic var registerParamState: RegisterParamStateObject?
    @objc dynamic var registerUsernameAvailableQueryState: RegisterUsernameAvailableQueryStateObject?
}

extension RegisterUsernameStateObject {
    var usernameAvailableQuery: String? {
        return registerUsernameAvailableQueryState?.query(username: registerParamState?.username)
    }
    var isUsernameAvaliable: Bool {
        return registerUsernameAvailableQueryState?.success != nil
    }
}

extension RegisterUsernameStateObject {
    
    static func create() -> (Realm) throws -> RegisterUsernameStateObject {
        return { realm in
            let _id = PrimaryKey.default
            let value: Any = [
                "_id": _id,
                "registerParamState": RegisterParamStateObject.createValues(),
                "registerUsernameAvailableQueryState": RegisterUsernameAvailableQueryStateObject.createValues(),
                ]
            return try realm.update(RegisterUsernameStateObject.self, value: value)
        }
    }
}

