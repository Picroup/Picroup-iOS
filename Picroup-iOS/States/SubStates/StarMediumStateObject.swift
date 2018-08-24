//
//  StarMediumStateObject.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/24.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift


final class StarMediumStateObject: PrimaryObject {
    
    @objc dynamic var success: String?
    @objc dynamic var error: String?
    @objc dynamic var trigger: Bool = false
}

extension StarMediumStateObject {
    var mediumId: String { return _id }
    var shouldQuery: Bool { return !trigger }
    func query(userId: String?) -> StarMediumMutation? {
        guard let userId = userId else { return nil }
        return trigger
            ? StarMediumMutation(userId: userId, mediumId: mediumId)
            : nil
    }
}

extension StarMediumStateObject {
    
    static func createValues(mediumId: String) -> Any {
        return [
            "_id": mediumId,
        ]
    }
}

extension StarMediumStateObject {
    
    enum Event {
        case onTrigger
        case onSuccess(StarMediumMutation.Data.StarMedium)
        case onError(Error)
    }
}

extension StarMediumStateObject: IsFeedbackStateObject {
    
    func reduce(event: Event, realm: Realm) {
        switch event {
        case .onTrigger:
            guard shouldQuery else { return }
            success = nil
            error = nil
            trigger = true
        case .onSuccess:
            success = UUID().uuidString
            error = nil
            trigger = false
        case .onError(let error):
            success = nil
            self.error = error.localizedDescription
            trigger = false
        }
    }
}
