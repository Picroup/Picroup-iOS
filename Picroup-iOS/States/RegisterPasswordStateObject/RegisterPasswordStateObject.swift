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

final class RegisterPasswordStateObject: PrimaryObject {
    
    @objc dynamic var registerParam: RegisterParamObject?
    @objc dynamic var isPasswordValid: Bool = false
}

extension RegisterPasswordStateObject {
    
    static func create() -> (Realm) throws -> RegisterPasswordStateObject {
        return { realm in
            let _id = PrimaryKey.default
            let value: Any = [
                "_id": _id,
                "registerParam": ["_id": _id, "password": ""],
                "isPasswordValid": false,
                ]
            return try realm.update(RegisterPasswordStateObject.self, value: value)
        }
    }
}

