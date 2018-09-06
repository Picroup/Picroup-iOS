//
//  UserSetAvatarQueryStateObject.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/9/3.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RealmSwift

final class UserSetAvatarQueryStateObject: PrimaryObject {
    
    typealias Query = (userId: String, imageKey: String)
    
    @objc dynamic var imageKey: String?
    @objc dynamic var error: String?
    @objc dynamic var trigger: Bool = false
}

extension UserSetAvatarQueryStateObject {
    func query(userId: String?) -> Query? {
        guard let userId = userId,
            let imageKey = imageKey
            else { return nil }
        return trigger
            ? (userId, imageKey)
            : nil
    }
}

extension UserSetAvatarQueryStateObject {
    
    static func createValues() -> Any {
        return  [
            "_id": PrimaryKey.default,
            "imageKey": nil,
        ]
    }
}

extension UserSetAvatarQueryStateObject {
    
    enum Event {
        case onChangeImageKey(String)
        case onSuccess(UserFragment)
        case onError(Error)
    }
}

extension UserSetAvatarQueryStateObject: IsFeedbackStateObject {
    
    func reduce(event: Event, realm: Realm) {
        switch event {
        case .onChangeImageKey(let imageKey):
            self.imageKey = imageKey
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


