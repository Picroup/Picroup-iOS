//
//  RegularPattern.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/6/7.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation

public struct RegularPattern {
    static let `default` = "^.{4,320}" // Less than 320 characters
    static let username = "[a-zA-Z0-9]{4,}" // At least 4 characters
    static let password = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)[a-zA-Z0-9$@$!%*?&]{8,}" // At least 8 characters with one upper case, one lowwer case and one number
    static let displayName = "^.{2,20}" //"[a-zA-Z0-9]{4,}" // At least 4 characters
    static let email = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
    static let chinesePhone = "^1\\d{10}$"
    static let code4 = "[0-9]{4}" // 4 digit
    static let code6 = "[0-9]{6}" // 6 digit
    static let number = "[0-9]{1,}"
    static let double = "^-?(?:0|[1-9]\\d{0,2}(?:,?\\d{3})*)(?:\\.\\d+)?$"
}

extension String {
    public func matchExpression(_ pattern: String) -> Bool {
        let regularExpression = try! NSRegularExpression(pattern: pattern, options: [])
        let range = regularExpression.rangeOfFirstMatch(in: self, options: [], range: NSRange(location: 0, length: count))
        return range.location == 0 && range.length == count
    }
}
