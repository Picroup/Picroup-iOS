//
//  CursorReputationsQueryStateObject.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/29.
//  Copyright © 2018年 luojie. All rights reserved.
//


import Foundation
import RealmSwift

final class CursorReputationsQueryStateObject: PrimaryObject {
    @objc dynamic var cursorReputations: CursorReputationsObject?
    @objc dynamic var error: String?
    @objc dynamic var isReload: Bool = false
    @objc dynamic var trigger: Bool = false
}

extension CursorReputationsQueryStateObject: IsCursorItemsStateObject {
    var cursorItemsObject: CursorReputationsObject? { return cursorReputations }
}

extension CursorReputationsQueryStateObject {
    
    func query(userId: String?) -> MyReputationsQuery? {
        guard let userId = userId else { return nil }
        return trigger == true
            ? MyReputationsQuery(userId: userId, cursor: cursorItemsObject?.cursor.value)
            : nil
    }
}

extension CursorReputationsQueryStateObject {
    
    static func createValues(id: String) -> Any {
        return  [
            "_id": id,
            "cursorReputations": ["_id": id],
        ]
    }
}

extension CursorReputationsQueryStateObject {
    
    enum Event {
        case onTriggerReload
        case onTriggerGetMore
        case onGetData(CursorReputationLinksFragment)
        case onGetError(Error)
    }
}


extension CursorReputationsQueryStateObject: IsFeedbackStateObject {
    
    func reduce(event: Event, realm: Realm) {
        switch event {
        case .onTriggerReload:
            isReload = true
            cursorReputations?.cursor.value = nil
            error = nil
            trigger = true
        case .onTriggerGetMore:
            guard shouldQueryMore else { return }
            isReload = false
            error = nil
            trigger = true
        case .onGetData(let data):
            if isReload {
                cursorReputations = CursorReputationsObject.create(from: data, id: _id)(realm)
                isReload = false
            } else {
                cursorReputations?.merge(from: data)(realm)
            }
            error = nil
            trigger = false
        case .onGetError(let error):
            self.error = error.localizedDescription
            trigger = false
        }
    }
}

