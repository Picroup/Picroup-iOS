//
//  UserSetDisplayNameQueryStateObject.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/9/3.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RealmSwift

final class UserSetDisplayNameQueryStateObject: PrimaryObject {
    
    @objc dynamic var displayName: String = ""
    @objc dynamic var error: String?
    @objc dynamic var trigger: Bool = false
}

extension UserSetDisplayNameQueryStateObject {
    var shouldQuery: Bool {
        return displayName.matchExpression(RegularPattern.displayName)
    }
    func query(userId: String?) -> UserSetDisplayNameQuery? {
        guard let userId = userId else { return nil }
        return trigger
            ? UserSetDisplayNameQuery(userId: userId, displayName: displayName)
            : nil
    }
}

extension UserSetDisplayNameQueryStateObject {
    
    static func createValues() -> Any {
        return  [
            "_id": PrimaryKey.default,
        ]
    }
}

extension UserSetDisplayNameQueryStateObject {
    
    enum Event {
        case onTriggerSetDisplayName(String)
        case onSuccess(UserFragment)
        case onError(Error)
    }
}

extension UserSetDisplayNameQueryStateObject: IsFeedbackStateObject {
    
    func reduce(event: Event, realm: Realm) {
        switch event {
        case .onTriggerSetDisplayName(let displayName):
            self.displayName = displayName
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


