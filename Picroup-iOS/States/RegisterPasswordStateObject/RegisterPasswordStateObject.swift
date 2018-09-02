//
//  RegisterPasswordStateObject.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/6/6.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift
import RxSwift
import RxCocoa

final class RegisterPasswordStateObject: VersionedPrimaryObject {
    
    @objc dynamic var registerParamState: RegisterParamStateObject?
    @objc dynamic var passwordValidQueryState: PasswordValidQueryStateObject?
}

extension RegisterPasswordStateObject {
    var validPasswordQuery: String? {
        return passwordValidQueryState?.query(password: registerParamState?.password)
    }
    var isPasswordValid: Bool {
        return passwordValidQueryState?.success != nil
    }
}

extension RegisterPasswordStateObject {
    
    static func create() -> (Realm) throws -> RegisterPasswordStateObject {
        return { realm in
            let _id = PrimaryKey.default
            let value: Any = [
                "_id": _id,
                "registerParamState": RegisterParamStateObject.createValues(clearPassword: true),
                "passwordValidQueryState": PasswordValidQueryStateObject.createValues(id: "\(self).\(_id)"),
                ]
            return try realm.update(RegisterPasswordStateObject.self, value: value)
        }
    }
}

