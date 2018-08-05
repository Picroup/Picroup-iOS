//
//  CursorMediaStateObject.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/7/23.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RealmSwift

class CursorMediaStateObject: PrimaryObject {
    @objc dynamic var cursorMedia: CursorMediaObject?
    @objc dynamic var error: String?
    @objc dynamic var isReload: Bool = false
    @objc dynamic var trigger: Bool = false
}

extension CursorMediaStateObject {
    var hasMore: Bool {
        return cursorMedia?.cursor.value != nil
    }
    var shouldQueryMore: Bool {
        return !trigger && hasMore
    }
    var isEmpty: Bool {
        guard let items = cursorMedia?.items else { return false }
        return trigger == false && error == nil && items.isEmpty
    }
}

extension CursorMediaStateObject {
    
    static func valuesBy(id: String) -> Any {
        return  [
            "_id": id,
            "cursorMedia": ["_id": id],
        ]
    }
}

extension CursorMediaStateObject {
    
    enum Event {
        case onTriggerReload
        case onTriggerGetMore
        case onGetData(CursorMediaFragment)
        case onGetError(Error)
    }
}

extension CursorMediaStateObject: IsFeedbackStateObject {
    
    func reduce(event: Event, realm: Realm) {
        switch event {
        case .onTriggerReload:
            isReload = true
            cursorMedia?.cursor.value = nil
            error = nil
            trigger = true
        case .onTriggerGetMore:
            guard shouldQueryMore else { return }
            isReload = false
            error = nil
            trigger = true
        case .onGetData(let data):
            if isReload {
                cursorMedia = CursorMediaObject.create(from: data, id: _id)(realm)
                isReload = false
            } else {
                cursorMedia?.merge(from: data)(realm)
            }
            error = nil
            trigger = false
        case .onGetError(let error):
            self.error = error.localizedDescription
            trigger = false
        }
    }
}

//class HotMediaStateObject: CursorMediaStateObject {}
