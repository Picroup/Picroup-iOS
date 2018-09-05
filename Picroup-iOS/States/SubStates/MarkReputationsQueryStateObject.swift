//
//  MarkReputationsQueryStateObject.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/29.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RealmSwift

final class MarkReputationsQueryStateObject: PrimaryObject {
    
    @objc dynamic var success: String?
    @objc dynamic var error: String?
    @objc dynamic var trigger: Bool = false
}

extension MarkReputationsQueryStateObject {
    
    func query(userId: String?) -> MarkReputationLinksAsViewedQuery? {
        guard let userId = userId else { return nil }
        return trigger == true
            ? MarkReputationLinksAsViewedQuery(userId: userId)
            : nil
    }
}

extension MarkReputationsQueryStateObject {
    
    static func createValues() -> Any {
        return  [
            "_id": PrimaryKey.default,
        ]
    }
}

extension MarkReputationsQueryStateObject {
    
    enum Event {
        case onTrigger
        case onSuccess(String)
        case onError(Error)
    }
}

extension MarkReputationsQueryStateObject: IsFeedbackStateObject {
    
    func reduce(event: Event, realm: Realm) {
        switch event {
        case .onTrigger:
            success = nil
            error = nil
            trigger = true
        case .onSuccess(let id):
            success = id
            error = nil
            trigger = false
        case .onError(let error):
            success = nil
            self.error = error.localizedDescription
            trigger = false
        }
    }
}
