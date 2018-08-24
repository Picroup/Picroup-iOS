//
//  RegisterCodeStateObject.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/6/6.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift
import RxSwift
import RxCocoa

final class RegisterCodeStateObject: PrimaryObject {
    
    @objc dynamic var sessionStateState: UserSessionStateObject?
    
    @objc dynamic var registerParam: RegisterParamObject?
    @objc dynamic var isCodeAvaliable: Bool = false
    
    @objc dynamic var registerError: String?
    @objc dynamic var triggerRegisterQuery: Bool = false
    
    @objc dynamic var phoneNumber: String?
    @objc dynamic var getVerifyCodeError: String?
    @objc dynamic var triggerGetVerifyCodeQuery: Bool = false
    
    @objc dynamic var snackbar: SnackbarObject?
}

extension RegisterCodeStateObject {
    var registerQuery: RegisterMutation? {
        guard let username = registerParam?.username,
            let password = registerParam?.password,
            let phoneNumber = registerParam?.phoneNumber,
            let code = registerParam?.code else {
            return nil
        }
        let next = RegisterMutation(username: username, password: password, phoneNumber: phoneNumber, code: code)
        return triggerRegisterQuery ? next : nil
    }
    var getVerifyCodeQuery: GetVerifyCodeMutation? {
        guard let phoneNumber = registerParam?.phoneNumber else { return nil }
        let next = GetVerifyCodeMutation(phoneNumber: phoneNumber)
        return triggerGetVerifyCodeQuery ? next : nil
    }
}

extension RegisterCodeStateObject {
    
    static func create() -> (Realm) throws -> RegisterCodeStateObject {
        return { realm in
            let _id = PrimaryKey.default
            let value: Any = [
                "_id": _id,
                "sessionStateState": ["_id": _id],
                "registerParam": ["_id": _id, "code": 0],
                "isCodeAvaliable": false,
                "phoneNumber": nil,
                "snackbar": ["_id": _id],
                ]
            return try realm.update(RegisterCodeStateObject.self, value: value)
        }
    }
}
