//
//  GetVerifyCodeQueryStateObject.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/9/2.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RealmSwift

final class GetVerifyCodeQueryStateObject: QueryStateObject {}

extension GetVerifyCodeQueryStateObject {
    func query(phoneNumber: String?) -> GetVerifyCodeMutation? {
        guard let phoneNumber = phoneNumber else { return nil }
        return trigger
            ? GetVerifyCodeMutation(phoneNumber: phoneNumber)
            : nil
    }
}
