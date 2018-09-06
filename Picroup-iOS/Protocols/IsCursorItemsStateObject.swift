//
//  IsCursorItemsStateObject.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/29.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation

protocol IsCursorItemsStateObject: AnyObject {
    associatedtype CursorItemsObject: IsCursorItemsObject
    var cursorItemsObject: CursorItemsObject? { get }
    var error: String? { get }
    var isReload: Bool { get }
    var trigger: Bool { get }
}

extension IsCursorItemsStateObject {
    var hasMore: Bool {
        return cursorItemsObject?.cursor.value != nil
    }
    var shouldQueryMore: Bool {
        return !trigger && hasMore
    }
    var isEmpty: Bool {
        guard let items = cursorItemsObject?.items else { return false }
        return trigger == false && error == nil && items.isEmpty
    }
}
