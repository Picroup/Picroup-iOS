//
//  ResetPasswordParamObject.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/23.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation

final class ResetPasswordParamObject: PrimaryObject {
    
    @objc dynamic var phoneNumber: String = ""
    @objc dynamic var password: String = ""
    @objc dynamic var token: String = ""
    @objc dynamic var code: Double = 0
}
