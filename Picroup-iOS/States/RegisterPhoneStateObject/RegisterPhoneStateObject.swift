//
//  RegisterPhoneStateObject.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/6/6.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift
import RxSwift
import RxCocoa

final class RegisterPhoneStateObject: VersionedPrimaryObject {
    
    @objc dynamic var registerParamState: RegisterParamStateObject?
    @objc dynamic var registerPhoneAvailableQueryState: RegisterPhoneAvailableQueryStateObject?
}

extension RegisterPhoneStateObject {
    var phoneNumberAvailableQuery: String? {
        return registerPhoneAvailableQueryState?.query(phoneNumber: registerParamState?.phoneNumber)
    }
    var isPhoneNumberValid: Bool {
        return registerPhoneAvailableQueryState?.success != nil
    }
}

extension RegisterPhoneStateObject {
    
    static func create() -> (Realm) throws -> RegisterPhoneStateObject {
        return { realm in
            let _id = PrimaryKey.default
            let value: Any = [
                "_id": _id,
                "registerParamState": RegisterParamStateObject.createValues(),
                "registerPhoneAvailableQueryState": RegisterPhoneAvailableQueryStateObject.createValues(),
                ]
            return try realm.update(RegisterPhoneStateObject.self, value: value)
        }
    }
}


