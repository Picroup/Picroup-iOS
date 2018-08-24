//
//  MeStateObject.swift
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

final class MeStateObject: VersionedPrimaryObject {
    
    @objc dynamic var session: UserSessionObject?
    
    @objc dynamic var selectedTabIndex: Int = 0
    
    @objc dynamic var myMediaState: CursorMediaStateObject?
    
    @objc dynamic var myStaredMediaState: CursorMediaStateObject?

    @objc dynamic var needUpdate: NeedUpdateStateObject?
    
    @objc dynamic var imageDetialRoute: ImageDetialRouteObject?
    @objc dynamic var reputationsRoute: ReputationsRouteObject?
    @objc dynamic var userFollowingsRoute: UserFollowingsRouteObject?
    @objc dynamic var userFollowersRoute: UserFollowersRouteObject?
    @objc dynamic var userBlockingsRoute: UserBlockingsRouteObject?
    @objc dynamic var updateUserRoute: UpdateUserRouteObject?
    @objc dynamic var feedbackRoute: FeedbackRouteObject?
    @objc dynamic var aboutAppRoute: AboutAppRouteObject?
    @objc dynamic var popRoute: PopRouteObject?
}

extension MeStateObject {
    
    enum Tab: Int {
        case myMedia
        case myStaredMedia
    }
}

extension MeStateObject {
    var myMediaQuery: MyMediaQuery? {
        guard let userId = session?.currentUserId else { return nil }
        return myMediaState?.trigger == true
            ? MyMediaQuery(userId: userId, cursor: myMediaState?.cursorMedia?.cursor.value, queryUserId: userId)
            : nil
    }
    var myStaredMediaQuery: MyStaredMediaQuery? {
        guard let userId = session?.currentUserId else { return nil }
        return myStaredMediaState?.trigger == true
            ? MyStaredMediaQuery(userId: userId, cursor: myStaredMediaState?.cursorMedia?.cursor.value)
            : nil
    }
}

extension MeStateObject {
    
    static func create() -> (Realm) throws -> MeStateObject {
        return { realm in
            let _id = PrimaryKey.default
            let value: Any = [
                "_id": _id,
                "session": ["_id": _id],
                "myMediaState": CursorMediaStateObject.createValues(id: PrimaryKey.myMediaId),
                "myStaredMediaState":  CursorMediaStateObject.createValues(id: PrimaryKey.myStaredMediaId),
                "needUpdate": ["_id": _id],
                "imageDetialRoute": ["_id": _id],
                "reputationsRoute": ["_id": _id],
                "userFollowingsRoute": ["_id": _id],
                "userFollowersRoute": ["_id": _id],
                "userBlockingsRoute": ["_id": _id],
                "updateUserRoute": ["_id": _id],
                "feedbackRoute": ["_id": _id],
                "aboutAppRoute": ["_id": _id],
                "popRoute": ["_id": _id],
                ]
            return try realm.update(MeStateObject.self, value: value)
        }
    }
}

