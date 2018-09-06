//
//  ResetPhoneAvailableQueryStateObject.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/9/2.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RealmSwift

final class ResetPhoneAvailableQueryStateObject: QueryStateObject {}

extension ResetPhoneAvailableQueryStateObject {
    func query(phoneNumber: String?) -> String? {
        return trigger ? phoneNumber : nil
    }
}
