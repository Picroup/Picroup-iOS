//
//  SaveCommentQueryStateObject.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/9/3.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RealmSwift

final class SaveCommentQueryStateObject: PrimaryObject {
    
    @objc dynamic var content: String = ""
    
    @objc dynamic var error: String?
    @objc dynamic var trigger: Bool = false
}

extension SaveCommentQueryStateObject {
    var mediumId: String { return _id }
    func query(userId: String?) -> SaveCommentMutation? {
        guard let userId = userId else { return nil }
        return trigger
            ? SaveCommentMutation(userId: userId, mediumId: mediumId, content: content)
            : nil
    }
    var shouldQuery: Bool {
        return !trigger && content.matchExpression(RegularPattern.default)
    }
}

extension SaveCommentQueryStateObject {
    
    static func createValues(id: String) -> Any {
        return [
            "_id": id,
        ]
    }
}

extension SaveCommentQueryStateObject {
    
    enum Event {
        case onContent(String)
        case onTrigger
        case onSuccess
        case onError(Error)
        case onChangeContent(String)
    }
}

extension SaveCommentQueryStateObject: IsFeedbackStateObject {
    
    func reduce(event: Event, realm: Realm) {
        switch event {
        case .onContent(let content):
            self.content = content
        case .onTrigger:
            guard shouldQuery else { return }
            error = nil
            trigger = true
        case .onSuccess:
            error = nil
            trigger = false
            content = ""
        case .onError(let error):
            self.error = error.localizedDescription
            trigger = false
        case .onChangeContent(let content):
            self.content = content
        }
    }
}
