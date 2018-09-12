//
//  StarMediumQueryStateObject.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/9/4.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RealmSwift

final class StarMediumQueryStateObject: PrimaryObject {
    @objc dynamic var mediumId: String?
    @objc dynamic var error: String?
    @objc dynamic var trigger: Bool = false
}

extension StarMediumQueryStateObject {
    var shouldQuery: Bool {
        return !trigger
    }
    func query(userId: String?) -> StarMediumMutation? {
        guard let userId = userId, let mediumId = mediumId else { return nil }
        return trigger
            ? StarMediumMutation(userId: userId, mediumId: mediumId)
            : nil
    }
}

extension StarMediumQueryStateObject {
    
    static func createValues() -> Any {
        return  [
            "_id": PrimaryKey.default,
            "success": nil,
            "error": nil,
            "trigger": false,
        ]
    }
}

extension StarMediumQueryStateObject {
    
    enum Event {
        case onTrigger(String)
        case onSuccess(StarMediumMutation.Data.StarMedium)
        case onError(Error)
    }
}

extension StarMediumQueryStateObject: IsFeedbackStateObject {
    
    func reduce(event: Event, realm: Realm) {
        switch event {
        case .onTrigger(let mediumId):
            guard shouldQuery else { return }
            self.mediumId = mediumId
            error = nil
            trigger = true
        case .onSuccess(let data):
            let medium = realm.create(MediumObject.self, value: data.snapshot, update: true)
            medium.stared.value = true
            error = nil
            trigger = false
        case .onError(let error):
            self.error = error.localizedDescription
            trigger = false
        }
    }
}

