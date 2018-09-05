//
//  MediumAddTagQueryStateObject.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/9/3.
//  Copyright © 2018年 luojie. All rights reserved.
//


import Foundation
import RealmSwift

final class MediumAddTagQueryStateObject: PrimaryObject {
    
    @objc dynamic var addTag: String?
    @objc dynamic var error: String?
    @objc dynamic var trigger: Bool = false
}

extension MediumAddTagQueryStateObject {
    var shouldQuery: Bool {
        return !trigger
    }
    func query(mediumId: String, currentUserId: String?) -> MediumAddTagQuery? {
        guard let userId = currentUserId,
            let tag = addTag else { return nil }
        return trigger == true
            ? MediumAddTagQuery(mediumId: mediumId, tag: tag, byUserId: userId)
            : nil
    }
}

extension MediumAddTagQueryStateObject {
    
    static func createValues() -> Any {
        return  [
            "_id": PrimaryKey.default,
        ]
    }
}
extension MediumAddTagQueryStateObject {
    
    enum Event {
        case onTriggerAddTag(String)
        case onSuccess(MediumFragment)
        case onError(Error)
    }
}

extension MediumAddTagQueryStateObject: IsFeedbackStateObject {
    
    func reduce(event: Event, realm: Realm) {
        switch event {
        case .onTriggerAddTag(let addTag):
            guard shouldQuery else { return }
            self.addTag = addTag
            error = nil
            trigger = true
        case .onSuccess(let data):
            realm.create(MediumObject.self, value: data.rawSnapshot, update: true)
            addTag = nil
            error = nil
            trigger = false
        case .onError(let error):
            self.error = error.localizedDescription
            trigger = false
        }
    }
}

