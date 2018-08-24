//
//  FeedbackStateObject.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/6/5.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift
import RxSwift
import RxCocoa
import Apollo

final class FeedbackStateObject: PrimaryObject {
    
    @objc dynamic var session: UserSessionObject?
    
    @objc dynamic var mediumId: String?
    @objc dynamic var toUserId: String?
    @objc dynamic var commentId: String?
    @objc dynamic var kind: String?
    @objc dynamic var content: String = ""
    
    @objc dynamic var savedFeedbackId: String?
    @objc dynamic var savedFeedbackError: String?
    @objc dynamic var triggerSaveFeedback: Bool = false

    @objc dynamic var routeState: RouteStateObject?
    @objc dynamic var snackbar: SnackbarObject?
}

extension FeedbackStateObject {
    var saveAppFeedbackQuery: SaveAppFeedbackMutation? {
        guard kind == FeedbackKind.app.rawValue,
            !content.isEmpty,
            let userId = session?.currentUserId
            else { return nil }
        let next = SaveAppFeedbackMutation(userId: userId, content: content)
        return triggerSaveFeedback ? next : nil
    }
    var saveUserFeedbackQuery: SaveUserFeedbackMutation? {
        guard kind == FeedbackKind.user.rawValue,
            !content.isEmpty,
            let userId = session?.currentUserId,
            let toUserId = toUserId
            else { return nil }
        let next = SaveUserFeedbackMutation(userId: userId, toUserId: toUserId, content: content)
        return triggerSaveFeedback ? next : nil
    }
    var saveMediumFeedbackQuery: SaveMediumFeedbackMutation? {
        guard kind == FeedbackKind.medium.rawValue,
            !content.isEmpty,
            let userId = session?.currentUserId,
            let mediumId = mediumId
            else { return nil }
        let next = SaveMediumFeedbackMutation(userId: userId, mediumId: mediumId, content: content)
        return triggerSaveFeedback ? next : nil
    }
    var saveCommentFeedbackQuery: SaveCommentFeedbackMutation? {
        guard kind == FeedbackKind.comment.rawValue,
            !content.isEmpty,
            let userId = session?.currentUserId,
            let commentId = commentId
            else { return nil }
        let next = SaveCommentFeedbackMutation(userId: userId, commentId: commentId, content: content)
        return triggerSaveFeedback ? next : nil
    }
    var shouldSaveFeedback: Bool {
        return !triggerSaveFeedback && content.matchExpression(RegularPattern.default)
    }
}

extension FeedbackStateObject {
    
    static func create(kind: String?, toUserId: String?, mediumId: String?, commentId: String?) -> (Realm) throws -> FeedbackStateObject {
        return { realm in
            let _id = PrimaryKey.default
            let feedbackId = PrimaryKey.feedbackId(kind: kind, toUserId: toUserId, mediumId: mediumId, commentId: commentId)
            let value: Snapshot = [
                "_id": feedbackId,
                "session": ["_id": _id],
                "kind": kind,
                "toUserId": toUserId,
                "mediumId": mediumId,
                "commentId": commentId,
                "routeState": RouteStateObject.createValues(),
                "snackbar": ["_id": _id],
                ]
            return try realm.update(FeedbackStateObject.self, value: value)
        }
    }
}
