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
    
    static func createValues() -> Any {
        return  [
            "_id": PrimaryKey.default,
        ]
    }
}

extension RegisterParamStateObject {
    
    enum Event {
        case onChangeUsername(String)
    }
}

extension RegisterParamStateObject: IsFeedbackStateObject {
    
    func reduce(event: Event, realm: Realm) {
        switch event {
        case .onChangeUsername(let username):
            self.username = username
        }
    }
}


