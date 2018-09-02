//
//  RegisterParamStateObject.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/9/2.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RealmSwift

final class RegisterParamStateObject: PrimaryObject {
    @objc dynamic var username: String = ""
    @objc dynamic var password: String = ""
    @objc dynamic var phoneNumber: String = ""
    @objc dynamic var code: Double = 0
}

extension RegisterParamStateObject {
    
    static func createValues(clearPassword: Bool = false) -> Any {
        var result: [String : Any] = [
            "_id": PrimaryKey.default,
            "code": 0,
            ]
        if clearPassword {
            result["password"] = ""
        }
        return result
    }
}

extension RegisterParamStateObject {
    
    enum Event {
        case onChangeUsername(String)
        case onChangePassword(String)
        case onChangePhoneNumber(String)
        case onChangeCode(String)
    }
}

extension RegisterParamStateObject: IsFeedbackStateObject {
    
    func reduce(event: Event, realm: Realm) {
        switch event {
        case .onChangeUsername(let username):
            self.username = username
        case .onChangePassword(let password):
            self.password = password
        case .onChangePhoneNumber(let phoneNumber):
            self.phoneNumber = phoneNumber
        case .onChangeCode(let codeText):
            let code = Double(codeText) ?? 0
            self.code = code
        }
    }
}


