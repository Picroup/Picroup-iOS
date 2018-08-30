//
//  CursorMediaQueryStateObject.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/7/23.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RealmSwift

class CursorMediaQueryStateObject: PrimaryObject {
    @objc dynamic var cursorMedia: CursorMediaObject?
    @objc dynamic var error: String?
    @objc dynamic var isReload: Bool = false
    @objc dynamic var trigger: Bool = false
}

extension CursorMediaQueryStateObject: IsCursorItemsStateObject {
    var cursorItemsObject: CursorMediaObject? { return cursorMedia }
}

extension CursorMediaQueryStateObject {
    
    static func createValues(id: String) -> Any {
        return  [
            "_id": id,
            "cursorMedia": ["_id": id],
        ]
    }
}

extension CursorMediaQueryStateObject {
    
    enum Event {
        case onTriggerReload
        case onTriggerGetMore
        case onGetData(CursorMediaFragment)
        case onGetSampleData(CursorMediaFragment)
        case onGetError(Error)
    }
}

extension CursorMediaQueryStateObject: IsFeedbackStateObject {
    
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
        case .onGetSampleData(let data):
            if isReload {
                cursorMedia = CursorMediaObject.create(from: data, id: _id)(realm)
                cursorMedia?.cursor.value = 0
                isReload = false
            } else {
                cursorMedia?.mergeSample(from: data)(realm)
                cursorMedia?.cursor.value = 0
            }
            error = nil
            trigger = false
        case .onGetError(let error):
            self.error = error.localizedDescription
            trigger = false
        }
    }
}

