//
//  ImageDetailStateObject.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/16.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift
import RxCocoa
import RxRealm

final class ImageDetailStateObject: PrimaryObject {
    
    @objc dynamic var session: UserSessionObject?
    @objc dynamic var isMediumDeleted: Bool = false

    @objc dynamic var medium: MediumObject?
    @objc dynamic var recommendMedia: CursorMediaObject?
    @objc dynamic var mediumError: String?
    @objc dynamic var triggerMediumQuery: Bool = false

    @objc dynamic var starMediumVersion: String?
    @objc dynamic var starMediumError: String?
    @objc dynamic var triggerStarMediumQuery: Bool = false

    @objc dynamic var myStaredMedia: CursorMediaObject?
    
    @objc dynamic var deleteMediumError: String?
    @objc dynamic var triggerDeleteMediumQuery: Bool = false
    
    @objc dynamic var blockMediumVersion: String?
    @objc dynamic var blockMediumError: String?
    @objc dynamic var triggerBlockMediumQuery: Bool = false
    
    @objc dynamic var shareMediumError: String?
    @objc dynamic var triggerShareMediumQuery: Bool = false
    
    @objc dynamic var needUpdate: NeedUpdateStateObject?
    
    @objc dynamic var loginRoute: LoginRouteObject?
    @objc dynamic var imageDetialRoute: ImageDetialRouteObject?
    @objc dynamic var imageCommetsRoute: ImageCommetsRouteObject?
    @objc dynamic var tagMediaRoute: TagMediaRouteObject?
    @objc dynamic var updateMediumTagsRoute: UpdateMediumTagsRouteObject?
    @objc dynamic var userRoute: UserRouteObject?
    @objc dynamic var feedbackRoute: FeedbackRouteObject?
    @objc dynamic var popRoute: PopRouteObject?
    
    @objc dynamic var snackbar: SnackbarObject?
}

extension ImageDetailStateObject {
    var mediumId: String { return _id }
    var mediumQuery: MediumQuery? {
        let (userId, withStared) = session?.currentUserId == nil
            ? ("", false)
            : (session!.currentUser!._id, true)
        let next = MediumQuery(userId: userId, mediumId: mediumId, cursor: recommendMedia?.cursor.value, withStared: withStared, queryUserId: session?.currentUserId)
        return triggerMediumQuery ? next : nil
    }
    var shouldQueryMoreRecommendMedia: Bool {
        return !triggerMediumQuery && hasMoreRecommendMedia
    }
    var hasMoreRecommendMedia: Bool {
        return recommendMedia?.cursor.value != nil
    }
    public var shouldStarMedium: Bool {
        return medium?.stared.value != true && !triggerStarMediumQuery
    }
    public var starMediumQuery: StarMediumMutation? {
        guard let userId = session?.currentUserId else { return nil }
        let next = StarMediumMutation(userId: userId, mediumId: mediumId)
        return triggerStarMediumQuery ? next : nil
    }
    var deleteMediumQuery: DeleteMediumMutation? {
        let next = DeleteMediumMutation(mediumId: mediumId)
        return triggerDeleteMediumQuery ? next : nil
    }
    public var shouldDeleteMedium: Bool {
        return !triggerDeleteMediumQuery
    }
    var shouldBlockMedium: Bool {
        return !triggerBlockMediumQuery
    }
    var blockUserQuery: BlockMediumMutation? {
        guard let userId = session?.currentUserId else { return nil }
        return triggerBlockMediumQuery
            ? BlockMediumMutation(userId: userId, mediumId: mediumId)
            : nil
    }
    var shareMediumQuery: (String, MediumItem)? {
        guard triggerShareMediumQuery else { return nil }
        guard let username = medium?.user?.username,
            let mediumItem = MediumItemHelper.mediumItem(from: medium) else { return nil }
        return (username, mediumItem)
    }
}

extension ImageDetailStateObject {
    
    static func create(mediumId: String) -> (Realm) throws -> ImageDetailStateObject {
        return { realm in
            let _id = PrimaryKey.default
            let value: Any = [
                "_id": mediumId,
                "session": ["_id": _id],
                "medium": ["_id": mediumId],
                "recommendMedia": ["_id": PrimaryKey.recommendMediaId(mediumId)],
                "myStaredMedia": ["_id": PrimaryKey.myStaredMediaId],
                "needUpdate": ["_id": _id],
                "loginRoute": ["_id": _id],
                "imageDetialRoute": ["_id": _id],
                "imageCommetsRoute": ["_id": _id],
                "tagMediaRoute": ["_id": _id],
                "updateMediumTagsRoute": ["_id": _id],
                "userRoute": ["_id": _id],
                "feedbackRoute": ["_id": _id],
                "popRoute": ["_id": _id],
                "snackbar": ["_id": _id],
                ]
            return try realm.update(ImageDetailStateObject.self, value: value)
        }
    }
}
