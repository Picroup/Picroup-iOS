//
//  UserMediaQueryStateObject.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/31.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation

final class UserMediaQueryStateObject: CursorMediaQueryStateObject {}
extension UserMediaQueryStateObject {
    func query(userId: String?, currentUserId: String?) -> MyMediaQuery? {
        guard let userId = userId else { return nil }
        return trigger
            ? MyMediaQuery(userId: userId, cursor: cursorMedia?.cursor.value, queryUserId: currentUserId)
            : nil
    }
}
