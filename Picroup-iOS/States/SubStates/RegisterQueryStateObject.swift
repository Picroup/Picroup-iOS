//
//  RegisterQueryStateObject.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/9/2.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RealmSwift

final class RegisterQueryStateObject: QueryStateObject {}

extension RegisterQueryStateObject {
    func query(username: String?, password: String?, phoneNumber: String?, code: Double?) -> RegisterMutation? {
        guard let username = username,
            let password = password,
            let phoneNumber = phoneNumber,
            let code = code else { return nil  }
        return trigger == true
            ? RegisterMutation(username: username, password: password, phoneNumber: phoneNumber, code: code)
            : nil
    }
}
