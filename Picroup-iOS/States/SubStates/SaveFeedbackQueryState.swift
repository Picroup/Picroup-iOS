//
//  SaveAppFeedbackQueryState.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/30.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift
import RxCocoa
import RxRealm

final class SaveFeedbackQueryState: PrimaryObject {
    
    @objc dynamic var mediumId: String?
    @objc dynamic var toUserId: String?
    @objc dynamic var commentId: String?
    @objc dynamic var kind: String?
    @objc dynamic var content: String = ""
    
    @objc dynamic var success: String?
    @objc dynamic var error: String?
    @objc dynamic var trigger: Bool = false
}

extension SaveFeedbackQueryState {
    func saveAppFeedbackQuery(userId: String?) -> SaveAppFeedbackMutation? {
        guard kind == FeedbackKind.app.rawValue,
            !content.isEmpty,
            let userId = userId
            else { return nil }
        return trigger
            ? SaveAppFeedbackMutation(userId: userId, content: content)
            : nil
    }
    
    func saveUserFeedbackQuery(userId: String?) -> SaveUserFeedbackMutation? {
        guard kind == FeedbackKind.user.rawValue,
            !content.isEmpty,
            let userId = userId,
            let toUserId = toUserId
            else { return nil }
        return trigger
            ? SaveUserFeedbackMutation(userId: userId, toUserId: toUserId, content: content)
            : nil
    }
    
    func saveMediumFeedbackQuery(userId: String?) -> SaveMediumFeedbackMutation? {
        guard kind == FeedbackKind.medium.rawValue,
            !content.isEmpty,
            let userId = userId,
            let mediumId = mediumId
            else { return nil }
        return trigger
            ? SaveMediumFeedbackMutation(userId: userId, mediumId: mediumId, content: content)
            : nil
    }
    
    func saveCommentFeedbackQuery(userId: String?) -> SaveCommentFeedbackMutation? {
        guard kind == FeedbackKind.comment.rawValue,
            !content.isEmpty,
            let userId = userId,
            let commentId = commentId
            else { return nil }
        return trigger
            ? SaveCommentFeedbackMutation(userId: userId, commentId: commentId, content: content)
            : nil
    }
    
    var shouldQuery: Bool {
        return !trigger && content.matchExpression(RegularPattern.default)
    }
}

extension SaveFeedbackQueryState {
    
    static func createValues(id: String, kind: String?, toUserId: String?, mediumId: String?, commentId: String?) -> Any {
        return [
            "_id": id,
            "kind": kind,
            "toUserId": toUserId,
            "mediumId": mediumId,
            "commentId": commentId,
        ]
    }
}

extension SaveFeedbackQueryState {
    
    enum Event {
        case onTrigger
        case onSuccess(String)
        case onError(Error)
        case onChangeContent(String)
    }
}

extension SaveFeedbackQueryState: IsFeedbackStateObject {
    
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
            content = ""
        case .onError(let error):
            success = nil
            self.error = error.localizedDescription
            trigger = false
        case .onChangeContent(let content):
            self.content = content
        }
    }
}
