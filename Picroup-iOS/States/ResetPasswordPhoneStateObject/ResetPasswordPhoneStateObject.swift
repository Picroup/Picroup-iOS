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

final class ResetPasswordParamObject: PrimaryObject {
    
    @objc dynamic var phoneNumber: String = ""
    @objc dynamic var password: String = ""
    @objc dynamic var token: String = ""
    @objc dynamic var code: Double = 0
}

final class ResetPasswordPhoneStateObject: PrimaryObject {
    
    @objc dynamic var resetPasswordParam: ResetPasswordParamObject?
    @objc dynamic var isPhoneNumberValid: Bool = false
    @objc dynamic var triggerValidPhoneQuery: Bool = false
}

extension ResetPasswordPhoneStateObject {
    var phoneNumberAvailableQuery: PhoneNumberAvailableQuery? {
        guard let phoneNumber = resetPasswordParam?.phoneNumber, !phoneNumber.isEmpty else {
            return nil
        }
        let next = PhoneNumberAvailableQuery(phoneNumber: phoneNumber)
        return triggerValidPhoneQuery ? next : nil
    }
    var shouldValidPhone: Bool {
        guard let phoneNumber = resetPasswordParam?.phoneNumber else { return false }
        return phoneNumber.matchExpression(RegularPattern.chinesePhone)
    }
}

extension ResetPasswordPhoneStateObject {
    
    static func create() -> (Realm) throws -> ResetPasswordPhoneStateObject {
        return { realm in
            let _id = PrimaryKey.default
            let value: Any = [
                "_id": _id,
                "resetPasswordParam": ["_id": _id],
                "isPhoneNumberValid": false,
                ]
            return try realm.update(ResetPasswordPhoneStateObject.self, value: value)
        }
    }
}
