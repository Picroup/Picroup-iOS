//
//  UserBlockingUsersQueryStateObject.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/31.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RealmSwift

final class UserBlockingUsersQueryStateObject: UsersQueryStateObject {}

extension UserBlockingUsersQueryStateObject {
    
    func query(userId: String?) -> UserBlockingUsersQuery? {
        guard let userId = userId else { return nil }
        return trigger
            ? UserBlockingUsersQuery(userId: userId)
            : nil
    }
}
