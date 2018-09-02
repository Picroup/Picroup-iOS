//
//  RegisterQueryStateObject.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/9/2.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RealmSwift

final class RegisterQueryStateObject: PrimaryObject {
    
    @objc dynamic var error: String?
    @objc dynamic var trigger: Bool = false
}

extension RegisterQueryStateObject {
    var shouldQuery: Bool {
        return !trigger
    }
    func query(username: String?, password: String?, phoneNumber: String?, code: Double?) -> RegisterMutation? {
        guard let username = username,
            let password = password,
            let phoneNumber = phoneNumber,
            let code = code else { return nil  }
        return trigger == true
            ? RegisterMutation(username: username, password: password, phoneNumber: phoneNumber, code: code)
            : nil
    }
}
extension RegisterQueryStateObject {
    
    static func createValues() -> Any {
        return  [
            "_id": PrimaryKey.default,
        ]
    }
}

extension RegisterQueryStateObject {
    
    enum Event {
        case onTrigger
        case onSuccess
        case onError(Error)
    }
}

extension RegisterQueryStateObject: IsFeedbackStateObject {
    
    func reduce(event: Event, realm: Realm) {
        switch event {
        case .onTrigger:
            guard shouldQuery else { return }
            error = nil
            trigger = true
        case .onSuccess:
            error = nil
            trigger = false
        case .onError(let error):
            self.error = error.localizedDescription
            trigger = false
        }
    }
}
