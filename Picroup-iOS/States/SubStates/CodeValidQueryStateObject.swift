//
//  CodeValidQueryStateObject.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/9/2.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RealmSwift

final class CodeValidQueryStateObject: PrimaryObject {
    
    @objc dynamic var success: String?
    @objc dynamic var error: String?
    @objc dynamic var trigger: Bool = false
}

extension CodeValidQueryStateObject {
    var shouldQuery: Bool {
        return !trigger
    }
    func query(code: Double?) -> Double? {
        return trigger ? code : nil
    }
}

extension CodeValidQueryStateObject {
    
    static func createValues(id: String) -> Any {
        return  [
            "_id": id,
            "success": nil,
            "error": nil,
            "trigger": false,
        ]
    }
}

extension CodeValidQueryStateObject {
    
    enum Event {
        case onTrigger
        case onSuccess
        case onError(Error)
    }
}

extension CodeValidQueryStateObject: IsFeedbackStateObject {
    
    func reduce(event: Event, realm: Realm) {
        switch event {
        case .onTrigger:
            guard shouldQuery else { return }
            success = nil
            error = nil
            trigger = true
        case .onSuccess:
            success = ""
            error = nil
            trigger = false
        case .onError(let error):
            success = nil
            self.error = error.localizedDescription
            trigger = false
        }
    }
}
