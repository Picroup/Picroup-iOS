//
//  PasswordValidQueryStateObject.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/9/2.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RealmSwift

final class PasswordValidQueryStateObject: QueryStateObject {}

extension PasswordValidQueryStateObject {
    func query(password: String?) -> String? {
        return trigger ? password : nil
    }
}
