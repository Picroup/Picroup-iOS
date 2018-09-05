//
//  MediumRemoveTagQueryStateObject.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/9/3.
//  Copyright © 2018年 luojie. All rights reserved.
//


import Foundation
import RealmSwift

final class MediumRemoveTagQueryStateObject: PrimaryObject {
    
    @objc dynamic var removeTag: String?
    @objc dynamic var error: String?
    @objc dynamic var trigger: Bool = false
}

extension MediumRemoveTagQueryStateObject {
    var shouldQuery: Bool {
        return !trigger
    }
    func query(mediumId: String, currentUserId: String?) -> MediumRemoveTagQuery? {
        guard let userId = currentUserId,
            let tag = removeTag else { return nil }
        return trigger == true
            ? MediumRemoveTagQuery(mediumId: mediumId, tag: tag, byUserId: userId)
            : nil
    }
}

extension MediumRemoveTagQueryStateObject {
    
    static func createValues() -> Any {
        return  [
            "_id": PrimaryKey.default,
        ]
    }
}
extension MediumRemoveTagQueryStateObject {
    
    enum Event {
        case onTriggerRemoveTag(String)
        case onSuccess(MediumFragment)
        case onError(Error)
    }
}

extension MediumRemoveTagQueryStateObject: IsFeedbackStateObject {
    
    func reduce(event: Event, realm: Realm) {
        switch event {
        case .onTriggerRemoveTag(let removeTag):
            guard shouldQuery else { return }
            self.removeTag = removeTag
            error = nil
            trigger = true
        case .onSuccess(let data):
            realm.create(MediumObject.self, value: data.rawSnapshot, update: true)
            removeTag = nil
            error = nil
            trigger = false
        case .onError(let error):
            self.error = error.localizedDescription
            trigger = false
        }
    }
}
