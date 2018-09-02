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

final class RegisterCodeStateObject: VersionedPrimaryObject {
    
    @objc dynamic var sessionState: UserSessionStateObject?
    
    @objc dynamic var registerParamState: RegisterParamStateObject?
    @objc dynamic var getVerifyCodeQueryState: GetVerifyCodeQueryStateObject?
    @objc dynamic var codeValidQueryState: CodeValidQueryStateObject?
    @objc dynamic var registerQueryState: RegisterQueryStateObject?
    
    @objc dynamic var snackbar: SnackbarObject?
}

extension RegisterCodeStateObject {
    var getVerifyCodeQuery: GetVerifyCodeMutation? {
        return getVerifyCodeQueryState?.query(phoneNumber: registerParamState?.phoneNumber)
    }
    var codeValidQuery: Double? {
        return codeValidQueryState?.query(code: registerParamState?.code)
    }
    var isCodeValid: Bool {
        return codeValidQueryState?.success != nil
    }
    var registerQuery: RegisterMutation? {
        return registerQueryState?.query(
            username: registerParamState?.username,
            password: registerParamState?.password,
            phoneNumber: registerParamState?.phoneNumber,
            code: registerParamState?.code
        )
    }
}

extension RegisterCodeStateObject {
    
    static func create() -> (Realm) throws -> RegisterCodeStateObject {
        return { realm in
            let _id = PrimaryKey.default
            let value: Any = [
                "_id": _id,
                "sessionState": UserSessionStateObject.createValues(),
                "registerParamState": RegisterParamStateObject.createValues(),
                "getVerifyCodeQueryState": GetVerifyCodeQueryStateObject.createValues(),
                "codeValidQueryState": CodeValidQueryStateObject.createValues(id: "\(self).\(_id)"),
                "registerQueryState": RegisterQueryStateObject.createValues(),
                "snackbar": ["_id": _id],
                ]
            return try realm.update(RegisterCodeStateObject.self, value: value)
        }
    }
}

