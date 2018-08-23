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

final class RegisterPhoneStateObject: PrimaryObject {
    
    @objc dynamic var registerParam: RegisterParamObject?
    @objc dynamic var isPhoneNumberValid: Bool = false
    @objc dynamic var triggerValidPhoneQuery: Bool = false
}

extension RegisterPhoneStateObject {
    var phoneNumberAvailableQuery: PhoneNumberAvailableQuery? {
        guard let phoneNumber = registerParam?.phoneNumber, !phoneNumber.isEmpty else {
            return nil
        }
        let next = PhoneNumberAvailableQuery(phoneNumber: phoneNumber)
        return triggerValidPhoneQuery ? next : nil
    }
    var shouldValidPhone: Bool {
        guard let phoneNumber = registerParam?.phoneNumber else { return false }
        return phoneNumber.matchExpression(RegularPattern.chinesePhone)
    }
}

extension RegisterPhoneStateObject {
    
    static func create() -> (Realm) throws -> RegisterPhoneStateObject {
        return { realm in
            let _id = PrimaryKey.default
            let value: Any = [
                "_id": _id,
                "registerParam": ["_id": _id],
                "isPhoneNumberValid": false,
                ]
            return try realm.update(RegisterPhoneStateObject.self, value: value)
        }
    }
}



