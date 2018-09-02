//
//  ResetPasswordCodeStateObject.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/15.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift
import RxSwift
import RxCocoa

final class ResetPasswordCodeStateObject: VersionedPrimaryObject {
    
    @objc dynamic var resetPasswordStateParam: ResetPasswordParamStateObject?
    @objc dynamic var getVerifyCodeQueryState: GetVerifyCodeQueryStateObject?
    @objc dynamic var codeValidQueryState: CodeValidQueryStateObject?
    @objc dynamic var verifyCodeQueryState: VerifyCodeQueryStateObject?
    
    @objc dynamic var routeState: RouteStateObject?
    @objc dynamic var snackbar: SnackbarObject?
}

extension ResetPasswordCodeStateObject {
    var getVerifyCodeQuery: GetVerifyCodeMutation? {
        return getVerifyCodeQueryState?.query(phoneNumber: resetPasswordStateParam?.phoneNumber)
    }
    var codeValidQuery: Double? {
        return codeValidQueryState?.query(code: resetPasswordStateParam?.code)
    }
    var isCodeValid: Bool {
        return codeValidQueryState?.success != nil
    }
    var verifyCodeQuery: VerifyCodeQuery? {
        return verifyCodeQueryState?.query(
            phoneNumber: resetPasswordStateParam?.phoneNumber,
            code: resetPasswordStateParam?.code
        )
    }
}

extension ResetPasswordCodeStateObject {
    
    static func create() -> (Realm) throws -> ResetPasswordCodeStateObject {
        return { realm in
            let _id = PrimaryKey.default
            let value: Any = [
                "_id": _id,
                "resetPasswordStateParam": ["_id": _id, "code": 0],
                "getVerifyCodeQueryState": GetVerifyCodeQueryStateObject.createValues(id: "\(self).\(_id).getVerifyCodeQueryState"),
                "codeValidQueryState": CodeValidQueryStateObject.createValues(id: "\(self).\(_id).codeValidQueryState"),
                "verifyCodeQueryState": VerifyCodeQueryStateObject.createValues(id: "\(self).\(_id).verifyCodeQueryState"),
                "routeState": RouteStateObject.createValues(),
                "snackbar": ["_id": _id],
                ]
            return try realm.update(ResetPasswordCodeStateObject.self, value: value)
        }
    }
}
