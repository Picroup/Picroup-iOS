//
//  VerifyCodeQueryStateObject.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/9/2.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RealmSwift

final class VerifyCodeQueryStateObject: PrimaryObject {
    
    @objc dynamic var error: String?
    @objc dynamic var trigger: Bool = false
}

extension VerifyCodeQueryStateObject {
    var shouldQuery: Bool {
        return !trigger
    }
    func query(phoneNumber: String?, code: Double?) -> VerifyCodeQuery? {
        guard let phoneNumber = phoneNumber,
            let code = code else { return nil  }
        return trigger == true
            ? VerifyCodeQuery(phoneNumber: phoneNumber, code: code)
            : nil
    }
}
extension VerifyCodeQueryStateObject {
    
    static func createValues() -> Any {
        return  [
            "_id": PrimaryKey.default,
        ]
    }
}

extension VerifyCodeQueryStateObject {
    
    enum Event {
        case onTrigger
        case onSuccess
        case onError(Error)
    }
}

extension VerifyCodeQueryStateObject: IsFeedbackStateObject {
    
    func reduce(event: Event, realm: Realm) {
        switch event {
        case .onTrigger:
            guard shouldQuery else { return }
            error = nil
            trigger = true
        case .onSuccess:
            error = nil
            trigger = false
        case .onError(let error):
            self.error = error.localizedDescription
            trigger = false
        }
    }
}
