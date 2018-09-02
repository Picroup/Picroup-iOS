//
//  ResetPasswordParamObject.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/23.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RealmSwift

final class ResetPasswordParamStateObject: PrimaryObject {
    
    @objc dynamic var phoneNumber: String = ""
    @objc dynamic var password: String = ""
    @objc dynamic var token: String = ""
    @objc dynamic var code: Double = 0
}

extension ResetPasswordParamStateObject {
    
    static func createValues() -> Any {
        return [
            "_id": PrimaryKey.default,
            "password": "",
            "code": 0,
        ]
    }
}

extension ResetPasswordParamStateObject {
    
    enum Event {
        case onChangePhoneNumber(String)
        case onChangePassword(String)
        case onChangeToken(String)
        case onChangeCode(String)
    }
}

extension ResetPasswordParamStateObject: IsFeedbackStateObject {
    
    func reduce(event: Event, realm: Realm) {
        switch event {
        case .onChangePhoneNumber(let phoneNumber):
            self.phoneNumber = phoneNumber
        case .onChangePassword(let password):
            self.password = password
        case .onChangeToken(let token):
            self.token = token
        case .onChangeCode(let codeText):
            let code = Double(codeText) ?? 0
            self.code = code
        }
    }
}


