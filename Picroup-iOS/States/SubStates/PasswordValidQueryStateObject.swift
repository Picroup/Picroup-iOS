//
//  PasswordValidQueryStateObject.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/9/2.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RealmSwift

final class PasswordValidQueryStateObject: PrimaryObject {
    
    @objc dynamic var success: String?
    @objc dynamic var error: String?
    @objc dynamic var trigger: Bool = false
}

extension PasswordValidQueryStateObject {
    var shouldQuery: Bool {
        return !trigger
    }
    func query(password: String?) -> String? {
        return trigger ? password : nil
    }
}

extension PasswordValidQueryStateObject {
    
    static func createValues(id: String) -> Any {
        return  [
            "_id": id,
            "success": nil,
            "error": nil,
            "trigger": false,
        ]
    }
}

extension PasswordValidQueryStateObject {
    
    enum Event {
        case onTrigger
        case onSuccess
        case onError(Error)
    }
}

extension PasswordValidQueryStateObject: IsFeedbackStateObject {
    
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

