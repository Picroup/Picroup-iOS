//
//  UserSetPasswordQueryStateObject.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/28.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift

final class UserSetPasswordQueryStateObject: PrimaryObject {
    
    @objc dynamic var sessionState: UserSessionStateObject?
    
    @objc dynamic var oldPassword: String = ""
    @objc dynamic var password: String = ""
    
    @objc dynamic var isOldPasswordValid: Bool = false
    @objc dynamic var isPasswordValid: Bool = false
    
    @objc dynamic var error: String?
    @objc dynamic var trigger: Bool = false
}

extension UserSetPasswordQueryStateObject {
    var query: UserSetPasswordQuery? {
        guard let userId = sessionState?.currentUserId else { return nil }
        return trigger
            ? UserSetPasswordQuery(userId: userId, password: password, oldPassword: oldPassword)
            : nil
    }
    var shouldSetPassword: Bool {
        return isOldPasswordValid && isPasswordValid && !trigger
    }
}

extension UserSetPasswordQueryStateObject {
    
    static func createValues() -> Any {
        let _id = PrimaryKey.default
        return [
            "_id": _id,
            "sessionState": UserSessionStateObject.createValues(),
            "oldPassword": "",
            "password": "",
            "isOldPasswordValid": false,
            "isPasswordValid": false,
        ]
    }
}

extension UserSetPasswordQueryStateObject {
    
    enum Event {
        case onChangeOldPassword(String)
        case onChangePassword(String)
        
        case onTrigger
        case onSuccess(UserFragment)
        case onError(Error)
    }
}

extension UserSetPasswordQueryStateObject: IsFeedbackStateObject {
    
    func reduce(event: Event, realm: Realm) {
        switch event {
        case .onChangeOldPassword(let password):
            self.oldPassword = password
            self.isOldPasswordValid = password.matchExpression(RegularPattern.password)
        case .onChangePassword(let password):
            self.password = password
            self.isPasswordValid = password.matchExpression(RegularPattern.password)
        case .onTrigger:
            guard shouldSetPassword else { return }
            error = nil
            trigger = true
        case .onSuccess(let data):
            sessionState?.reduce(event: .onUpdateUser(data), realm: realm)
            error = nil
            trigger = false
        case .onError(let error):
            self.error = error.localizedDescription
            trigger = false
        }
    }
}
