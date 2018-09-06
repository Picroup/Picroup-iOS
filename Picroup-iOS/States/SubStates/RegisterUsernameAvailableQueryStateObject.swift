//
//  RegisterUsernameAvailableQueryStateObject.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/9/2.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RealmSwift

final class RegisterUsernameAvailableQueryStateObject: QueryStateObject {}

extension RegisterUsernameAvailableQueryStateObject {
    func query(username: String?) -> String? {
        return trigger ? username : nil
    }
}
