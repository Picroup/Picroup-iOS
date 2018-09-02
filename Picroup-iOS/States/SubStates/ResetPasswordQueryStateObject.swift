//
//  ResetPasswordQueryStateObject.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/9/2.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RealmSwift

final class ResetPasswordQueryStateObject: QueryStateObject {}

extension ResetPasswordQueryStateObject {
    func query(phoneNumber: String?, password: String?, token: String?) -> ResetPasswordMutation? {
        guard let phoneNumber = phoneNumber,
            let password = password,
            let token = token else { return nil }
        return trigger
            ? ResetPasswordMutation(phoneNumber: phoneNumber, password: password, token: token)
            : nil
    }
}


