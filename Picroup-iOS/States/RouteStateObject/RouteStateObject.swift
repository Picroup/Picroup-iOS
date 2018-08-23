//
//  RouteState.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/15.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift
import RxSwift
import RxCocoa
import RxRealm

final class RouteStateObject: PrimaryObject {
    
    @objc dynamic var session: UserSessionObject?
    @objc dynamic var imageDetialRoute: ImageDetialRouteObject?
    @objc dynamic var imageCommetsRoute: ImageCommetsRouteObject?
    @objc dynamic var tagMediaRoute: TagMediaRouteObject?
    @objc dynamic var updateMediumTagsRoute: UpdateMediumTagsRouteObject?
    @objc dynamic var reputationsRoute: ReputationsRouteObject?
    @objc dynamic var createImageRoute: CreateImageRouteObject?
    @objc dynamic var userRoute: UserRouteObject?
    @objc dynamic var updateUserRoute: UpdateUserRouteObject?
    
    @objc dynamic var userFollowingsRoute: UserFollowingsRouteObject?
    @objc dynamic var userFollowersRoute: UserFollowersRouteObject?
    @objc dynamic var searchUserRoute: SearchUserRouteObject?
    @objc dynamic var userBlockingsRoute: UserBlockingsRouteObject?

    @objc dynamic var loginRoute: LoginRouteObject?
    @objc dynamic var resetPasswordRoute: ResetPasswordRouteObject?
    @objc dynamic var backToLoginRoute: BackToLoginRouteObject?
    @objc dynamic var feedbackRoute: FeedbackRouteObject?
    @objc dynamic var aboutAppRoute: AboutAppRouteObject?
    
    @objc dynamic var popRoute: PopRouteObject?
    
    @objc dynamic var snackbar: SnackbarObject?
}

extension RouteStateObject {
    
    static func create() -> (Realm) throws -> RouteStateObject {
        return { realm in
            let _id = PrimaryKey.default
            let value: Any = [
                "_id": _id,
                "session": ["_id": _id],
                "imageDetialRoute": ["_id": _id],
                "imageCommetsRoute": ["_id": _id],
                "tagMediaRoute": ["_id": _id],
                "updateMediumTagsRoute": ["_id": _id],
                "reputationsRoute": ["_id": _id],
                "createImageRoute": ["_id": _id],
                "userRoute": ["_id": _id],
                "updateUserRoute": ["_id": _id],
                "userFollowingsRoute": ["_id": _id],
                "userFollowersRoute": ["_id": _id],
                "searchUserRoute": ["_id": _id],
                "userBlockingsRoute": ["_id": _id],
                "loginRoute": ["_id": _id],
                "resetPasswordRoute": ["_id": _id],
                "backToLoginRoute": ["_id": _id],
                "feedbackRoute": ["_id": _id],
                "aboutAppRoute": ["_id": _id],
                "popRoute": ["_id": _id],
                "snackbar": ["_id": _id],
                ]
            return try realm.update(RouteStateObject.self, value: value)
        }
    }
}
