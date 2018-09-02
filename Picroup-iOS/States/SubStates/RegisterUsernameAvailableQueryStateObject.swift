//
//  RegisterUsernameAvailableQueryStateObject.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/9/2.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RealmSwift

final class RegisterUsernameAvailableQueryStateObject: PrimaryObject {
    
    @objc dynamic var success: String?
    @objc dynamic var error: String?
    @objc dynamic var trigger: Bool = false
}

extension RegisterUsernameAvailableQueryStateObject {
    var shouldQuery: Bool {
        return !trigger
    }
    func query(username: String?) -> String? {
        return trigger ? username : nil
    }
}

extension RegisterUsernameAvailableQueryStateObject {
    
    static func createValues() -> Any {
        return  [
            "_id": PrimaryKey.default,
            "success": nil,
            "error": nil,
            "trigger": false,
        ]
    }
}

extension RegisterUsernameAvailableQueryStateObject {
    
    enum Event {
        case onTrigger
        case onSuccess
        case onError(Error)
    }
}

extension RegisterUsernameAvailableQueryStateObject: IsFeedbackStateObject {
    
    func reduce(event: Event, realm: Realm) {
        switch event {
        case .onTrigger:
            guard shouldQuery else { return }
            success = nil
            error = nil
            trigger = true
        case .onSuccess:
            success = ""
            error = nil
            trigger = false
        case .onError(let error):
            success = nil
            self.error = error.localizedDescription
            trigger = false
        }
    }
}
