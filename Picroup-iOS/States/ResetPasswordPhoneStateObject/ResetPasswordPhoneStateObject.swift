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
    
    @objc dynamic var resetPasswordStateParam: ResetPasswordParamStateObject?
    @objc dynamic var resetPhoneAvailableQueryState: ResetPhoneAvailableQueryStateObject?
//    @objc dynamic var isPhoneNumberValid: Bool = false
//    @objc dynamic var triggerValidPhoneQuery: Bool = false
}

extension ResetPasswordPhoneStateObject {
    var phoneNumberAvailableQuery: String? {
        return resetPhoneAvailableQueryState?.query(phoneNumber: resetPasswordStateParam?.phoneNumber)
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
                "resetPasswordStateParam": RegisterParamStateObject.createValues(),
                "resetPhoneAvailableQueryState": ResetPhoneAvailableQueryStateObject.createValues(),
                ]
            return try realm.update(ResetPasswordPhoneStateObject.self, value: value)
        }
    }
}
