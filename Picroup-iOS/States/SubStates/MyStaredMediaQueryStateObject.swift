//
//  MyStaredMediaQueryStateObject.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/31.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation

final class MyStaredMediaQueryStateObject: CursorMediaQueryStateObject {}
extension MyStaredMediaQueryStateObject {
    func query(userId: String?) -> MyStaredMediaQuery? {
        guard let userId = userId else { return nil }
        return trigger
            ? MyStaredMediaQuery(userId: userId, cursor: cursorMedia?.cursor.value)
            : nil
    }
}
