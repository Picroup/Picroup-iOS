//
//  QueryStateObject.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/9/2.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RealmSwift

class QueryStateObject: PrimaryObject {
    @objc dynamic var success: String?
    @objc dynamic var error: String?
    @objc dynamic var trigger: Bool = false
}

extension QueryStateObject {
    var shouldQuery: Bool {
        return !trigger
    }
}

extension QueryStateObject {
    
    static func createValues(id: String) -> Any {
        return  [
            "_id": id,
            "success": nil,
            "error": nil,
            "trigger": false,
        ]
    }
}

extension QueryStateObject {
    
    enum Event {
        case onTrigger
        case onSuccess(String)
        case onError(Error)
    }
}

extension QueryStateObject: IsFeedbackStateObject {
    
    func reduce(event: Event, realm: Realm) {
        switch event {
        case .onTrigger:
            guard shouldQuery else { return }
            success = nil
            error = nil
            trigger = true
        case .onSuccess(let data):
            success = data
            error = nil
            trigger = false
        case .onError(let error):
            success = nil
            self.error = error.localizedDescription
            trigger = false
        }
    }
}
