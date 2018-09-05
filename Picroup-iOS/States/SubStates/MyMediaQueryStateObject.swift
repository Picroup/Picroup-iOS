//
//  File.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/31.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation

final class MyMediaQueryStateObject: CursorMediaQueryStateObject {}
extension MyMediaQueryStateObject {
    func query(userId: String?) -> MyMediaQuery? {
        guard let userId = userId else { return nil }
        return trigger
            ? MyMediaQuery(userId: userId, cursor: cursorMedia?.cursor.value, queryUserId: userId)
            : nil
    }
}


