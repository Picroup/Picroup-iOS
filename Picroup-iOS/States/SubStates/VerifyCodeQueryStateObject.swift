//
//  VerifyCodeQueryStateObject.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/9/2.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RealmSwift

final class VerifyCodeQueryStateObject: QueryStateObject {}

extension VerifyCodeQueryStateObject {
    func query(phoneNumber: String?, code: Double?) -> VerifyCodeQuery? {
        guard let phoneNumber = phoneNumber,
            let code = code else { return nil  }
        return trigger == true
            ? VerifyCodeQuery(phoneNumber: phoneNumber, code: code)
            : nil
    }
}
