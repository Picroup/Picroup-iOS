//
//  CursorCommentsQueryStateObject.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/9/3.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RealmSwift

class CursorCommentsQueryStateObject: PrimaryObject {
    @objc dynamic var cursorComments: CursorCommentsObject?
    @objc dynamic var error: String?
    @objc dynamic var isReload: Bool = false
    @objc dynamic var trigger: Bool = false
}

extension CursorCommentsQueryStateObject: IsCursorItemsStateObject {
    var cursorItemsObject: CursorCommentsObject? { return cursorComments }
}

extension CursorCommentsQueryStateObject {
    
    static func createValues(id: String) -> Any {
        return  [
            "_id": id,
            "cursorComments": ["_id": id],
        ]
    }
}

extension CursorCommentsQueryStateObject {
    
    enum Event {
        case onTriggerReload
        case onTriggerGetMore
        case onGetData(CursorCommentsFragment)
        case onGetError(Error)
        case onCreate(CommentObject)
    }
}

extension CursorCommentsQueryStateObject: IsFeedbackStateObject {
    
    func reduce(event: Event, realm: Realm) {
        switch event {
        case .onTriggerReload:
            isReload = true
            cursorComments?.cursor.value = nil
            error = nil
            trigger = true
        case .onTriggerGetMore:
            guard shouldQueryMore else { return }
            isReload = false
            error = nil
            trigger = true
        case .onGetData(let data):
            if isReload {
                cursorComments = CursorCommentsObject.create(from: data, id: _id)(realm)
                isReload = false
            } else {
                cursorComments?.merge(from: data)(realm)
            }
            error = nil
            trigger = false
        case .onGetError(let error):
            self.error = error.localizedDescription
            trigger = false
        case .onCreate(let comment):
            cursorComments?.items.insert(comment, at: 0)
        }
    }
}

