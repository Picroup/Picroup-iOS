//
//  UserSession.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/14.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RealmSwift

final class UserSessionObject: PrimaryObject {
    @objc dynamic var currentUser: UserObject?
}

extension UserSessionObject {
    var isLogin: Bool {
        return currentUser != nil
    }
}

