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

final class ResetPasswordCodeStateObject: PrimaryObject {
    
    @objc dynamic var resetPasswordParam: ResetPasswordParamObject?
    @objc dynamic var isCodeAvaliable: Bool = false
    
    @objc dynamic var verifyCodeError: String?
    @objc dynamic var triggerVerifyCodeQuery: Bool = false
    
    @objc dynamic var phoneNumber: String?
    @objc dynamic var getVerifyCodeError: String?
    @objc dynamic var triggerGetVerifyCodeQuery: Bool = false
    
    @objc dynamic var routeState: RouteStateObject?

    @objc dynamic var snackbar: SnackbarObject?
}

extension ResetPasswordCodeStateObject {
    var verifyCodeQuery: VerifyCodeQuery? {
        guard let phoneNumber = resetPasswordParam?.phoneNumber,
            let code = resetPasswordParam?.code else {
                return nil
        }
        return triggerVerifyCodeQuery
            ? VerifyCodeQuery(phoneNumber: phoneNumber, code: code)
            : nil
    }
    var getVerifyCodeQuery: GetVerifyCodeMutation? {
        guard let phoneNumber = resetPasswordParam?.phoneNumber else { return nil }
        let next = GetVerifyCodeMutation(phoneNumber: phoneNumber)
        return triggerGetVerifyCodeQuery ? next : nil
    }
}

extension ResetPasswordCodeStateObject {
    
    static func create() -> (Realm) throws -> ResetPasswordCodeStateObject {
        return { realm in
            let _id = PrimaryKey.default
            let value: Any = [
                "_id": _id,
                "resetPasswordParam": ["_id": _id, "code": 0],
                "isCodeAvaliable": false,
                "phoneNumber": nil,
                "routeState": RouteStateObject.createValues(),
                "snackbar": ["_id": _id],
                ]
            return try realm.update(ResetPasswordCodeStateObject.self, value: value)
        }
    }
}
