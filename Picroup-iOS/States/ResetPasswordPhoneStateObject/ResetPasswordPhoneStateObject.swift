//
//  ResetPasswordPhoneStateObject.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/15.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift
import RxSwift
import RxCocoa

final class ResetPasswordPhoneStateObject: VersionedPrimaryObject {
    
    @objc dynamic var resetPasswordParamState: ResetPasswordParamStateObject?
    @objc dynamic var resetPhoneAvailableQueryState: ResetPhoneAvailableQueryStateObject?
}

extension ResetPasswordPhoneStateObject {
    var phoneNumberAvailableQuery: String? {
        return resetPhoneAvailableQueryState?.query(phoneNumber: resetPasswordParamState?.phoneNumber)
    }
    var isPhoneNumberValid: Bool {
        return resetPhoneAvailableQueryState?.success != nil
    }
}

extension ResetPasswordPhoneStateObject {
    
    static func create() -> (Realm) throws -> ResetPasswordPhoneStateObject {
        return { realm in
            let _id = PrimaryKey.default
            let value: Any = [
                "_id": _id,
                "resetPasswordParamState": RegisterParamStateObject.createValues(),
                "resetPhoneAvailableQueryState": ResetPhoneAvailableQueryStateObject.createValues(id: "\(self).\(_id).resetPhoneAvailableQueryState"),
                ]
            return try realm.update(ResetPasswordPhoneStateObject.self, value: value)
        }
    }
}
