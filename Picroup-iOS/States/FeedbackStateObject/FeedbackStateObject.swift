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

final class FeedbackStateObject: VersionedPrimaryObject {
    
    @objc dynamic var sessionState: UserSessionStateObject?
    @objc dynamic var saveFeedbackQueryState: SaveFeedbackQueryState?
    @objc dynamic var routeState: RouteStateObject?
    @objc dynamic var snackbar: SnackbarObject?
}

extension FeedbackStateObject {
    var saveAppFeedbackQuery: SaveAppFeedbackMutation? {
        return saveFeedbackQueryState?.saveAppFeedbackQuery(userId: sessionState?.currentUserId)
    }
    var saveUserFeedbackQuery: SaveUserFeedbackMutation? {
        return saveFeedbackQueryState?.saveUserFeedbackQuery(userId: sessionState?.currentUserId)
    }
    var saveMediumFeedbackQuery: SaveMediumFeedbackMutation? {
        return saveFeedbackQueryState?.saveMediumFeedbackQuery(userId: sessionState?.currentUserId)
    }
    var saveCommentFeedbackQuery: SaveCommentFeedbackMutation? {
        return saveFeedbackQueryState?.saveCommentFeedbackQuery(userId: sessionState?.currentUserId)
    }
}

extension FeedbackStateObject {
    
    static func create(kind: String?, toUserId: String?, mediumId: String?, commentId: String?) -> (Realm) throws -> FeedbackStateObject {
        return { realm in
            let _id = PrimaryKey.default
            let feedbackId = PrimaryKey.feedbackId(kind: kind, toUserId: toUserId, mediumId: mediumId, commentId: commentId)
            let value: Snapshot = [
                "_id": feedbackId,
                "sessionState": UserSessionStateObject.createValues(),
                "saveFeedbackQueryState": SaveFeedbackQueryState.createValues(id: feedbackId, kind: kind, toUserId: toUserId, mediumId: mediumId, commentId: commentId),
                "routeState": RouteStateObject.createValues(),
                "snackbar": ["_id": _id],
                ]
            return try realm.update(FeedbackStateObject.self, value: value)
        }
    }
}
