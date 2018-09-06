//
//  UsersQueryStateObject.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/31.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RealmSwift

class UsersQueryStateObject: PrimaryObject {
    
    let userBlockings = List<UserObject>()
    @objc dynamic var error: String?
    @objc dynamic var trigger: Bool = false
}

extension UsersQueryStateObject {
    var isEmpty: Bool {
        return trigger == false && error == nil && userBlockings.isEmpty
    }
}

extension UsersQueryStateObject {
    
    static func createValues(id: String) -> Any {
        return  [
            "_id": id,
            "userBlockings": [],
        ]
    }
}

extension UsersQueryStateObject {
    
    enum Event {
        case onTrigger
        case onGetData([UserFragment])
        case onGetError(Error)
    }
}

extension UsersQueryStateObject: IsFeedbackStateObject {
    
    func reduce(event: Event, realm: Realm) {
        switch event {
        case .onTrigger:
            error = nil
            trigger = true
        case .onGetData(let data):
        {
            userBlockings.removeAll()
            let users: [UserObject] = data.map {
                let user = realm.create(UserObject.self, value: $0.snapshot, update: true)
                user.blocked.value = true
                return user
            }
            userBlockings.append(objectsIn: users)
        }()
            error = nil
            trigger = false
        case .onGetError(let error):
            self.error = error.localizedDescription
            trigger = false
        }
    }
}

