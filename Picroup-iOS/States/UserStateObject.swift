//
//  UserStateObject.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/18.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift
import RxCocoa
import RxRealm

final class UserStateObject: PrimaryObject {
    
    @objc dynamic var version: String?
    
    @objc dynamic var session: UserSessionObject?
    
    @objc dynamic var user: UserObject?
    @objc dynamic var userError: String?
    @objc dynamic var triggerUserQuery: Bool = false
    
    @objc dynamic var userMediaState: CursorMediaStateObject?
    
    @objc dynamic var followUserVersion: String?
    @objc dynamic var followUserError: String?
    @objc dynamic var triggerFollowUserQuery: Bool = false
    
    @objc dynamic var unfollowUserVersion: String?
    @objc dynamic var unfollowUserError: String?
    @objc dynamic var triggerUnfollowUserQuery: Bool = false
    
    @objc dynamic var needUpdate: NeedUpdateStateObject?

    @objc dynamic var imageDetialRoute: ImageDetialRouteObject?
    @objc dynamic var userFollowingsRoute: UserFollowingsRouteObject?
    @objc dynamic var userFollowersRoute: UserFollowersRouteObject?
    @objc dynamic var feedbackRoute: FeedbackRouteObject?
    @objc dynamic var popRoute: PopRouteObject?
    
    @objc dynamic var snackbar: SnackbarObject?
}

extension UserStateObject {
    var userId: String { return _id }
    var userQuery: UserQuery? {
        let (byUserId, withFollowed) = session?.currentUser?._id == nil
            ? ("", false)
            : (session!.currentUser!._id, true)
        let next = UserQuery(userId: userId, followedByUserId: byUserId, withFollowed: withFollowed)
        return triggerUserQuery ? next : nil
    }
    var userMediaQuery: MyMediaQuery? {
        return userMediaState?.trigger == true
            ? MyMediaQuery(userId: userId, cursor: userMediaState?.cursorMedia?.cursor.value)
            : nil
    }
    var shouldFollowUser: Bool {
        return user?.followed.value == false && !triggerFollowUserQuery
    }
    var followUserQuery: FollowUserMutation? {
        guard
            let userId = session?.currentUser?._id,
            let toUserId = user?._id else {
                return nil
        }
        return triggerFollowUserQuery ? FollowUserMutation(userId: userId, toUserId: toUserId) : nil
    }
    var shouldUnfollowUser: Bool {
        return user?.followed.value == true && !triggerUnfollowUserQuery
    }
    var unfollowUserQuery: UnfollowUserMutation? {
        guard
            let userId = session?.currentUser?._id,
            let toUserId = user?._id else {
                return nil
        }
        return triggerUnfollowUserQuery ? UnfollowUserMutation(userId: userId, toUserId: toUserId) : nil
    }
}

extension UserStateObject {
    
    static func create(userId: String) -> (Realm) throws -> UserStateObject {
        return { realm in
            let _id = PrimaryKey.default
            let value: Any = [
                "_id": userId,
                "session": ["_id": _id],
                "user": ["_id": userId],
                "userMediaState": CursorMediaStateObject.valuesBy(id: PrimaryKey.userMediaId(userId)),
                "needUpdate": ["_id": _id],
                "imageDetialRoute": ["_id": _id],
                "userFollowingsRoute": ["_id": _id],
                "userFollowersRoute": ["_id": _id],
                "feedbackRoute": ["_id": _id],
                "popRoute": ["_id": _id],
                "snackbar": ["_id": _id],
                ]
            return try realm.update(UserStateObject.self, value: value)
        }
    }
}

extension UserStateObject {
    
    enum Event {
        case onTriggerReloadUser
        case onGetUserSuccess(UserQuery.Data.User)
        case onGetUserError(Error)
        
        case userMediaState(CursorMediaStateObject.Event)

        case onTriggerFollowUser
        case onFollowUserSuccess(FollowUserMutation.Data.FollowUser)
        case onFollowUserError(Error)
        
        case onTriggerUnfollowUser
        case onUnfollowUserSuccess(UnfollowUserMutation.Data.UnfollowUser)
        case onUnfollowUserError(Error)
        
        case onTriggerShowImage(String)
        case onTriggerShowUserFollowings
        case onTriggerShowUserFollowers
        case onTriggerUserFeedback
        case onTriggerPop
    }
}

extension UserStateObject: IsFeedbackStateObject {
    
    func reduce(event: Event, realm: Realm) {
        switch event {
        case .onTriggerReloadUser:
            userError = nil
            triggerUserQuery = true
        case .onGetUserSuccess(let data):
            user = realm.create(UserObject.self, value: data.snapshot, update: true)
            userError = nil
            triggerUserQuery = false
        case .onGetUserError(let error):
            userError = error.localizedDescription
            triggerUserQuery = false
            
        case .userMediaState(let event):
            userMediaState?.reduce(event: event, realm: realm)
            
        case .onTriggerFollowUser:
            guard shouldFollowUser else { return }
            followUserVersion = nil
            followUserError = nil
            triggerFollowUserQuery = true
        case .onFollowUserSuccess(let data):
            user = realm.create(UserObject.self, value: data.snapshot, update: true)
            followUserVersion = UUID().uuidString
            followUserError = nil
            triggerFollowUserQuery = false
            needUpdate?.myInterestedMedia = true

            snackbar?.message = "已关注 @\(user?.username ?? "")"
            snackbar?.version = UUID().uuidString
        case .onFollowUserError(let error):
            followUserVersion = nil
            followUserError = error.localizedDescription
            triggerFollowUserQuery = false
            
        case .onTriggerUnfollowUser:
            guard shouldUnfollowUser else { return }
            unfollowUserVersion = nil
            unfollowUserError = nil
            triggerUnfollowUserQuery = true
        case .onUnfollowUserSuccess(let data):
            user = realm.create(UserObject.self, value: data.snapshot, update: true)
            unfollowUserVersion = UUID().uuidString
            unfollowUserError = nil
            triggerUnfollowUserQuery = false
            needUpdate?.myInterestedMedia = true

            snackbar?.message = "已取消关注 @\(user?.username ?? "")"
            snackbar?.version = UUID().uuidString
        case .onUnfollowUserError(let error):
            unfollowUserVersion = nil
            unfollowUserError = error.localizedDescription
            triggerUnfollowUserQuery = false
            
        case .onTriggerShowImage(let mediumId):
            imageDetialRoute?.mediumId = mediumId
            imageDetialRoute?.version = UUID().uuidString
        case .onTriggerShowUserFollowings:
            userFollowingsRoute?.userId = user?._id
            userFollowingsRoute?.version = UUID().uuidString
        case .onTriggerShowUserFollowers:
            userFollowersRoute?.userId = user?._id
            userFollowersRoute?.version = UUID().uuidString
        case .onTriggerUserFeedback:
            feedbackRoute?.triggerUser(toUserId: userId)
        case .onTriggerPop:
            popRoute?.version = UUID().uuidString
        }
        version = UUID().uuidString
    }
}

final class UserStateStore {
    
    let states: Driver<UserStateObject>
    private let _state: UserStateObject
    private let userId: String

    init(userId: String) throws {
        let realm = try Realm()
        let _state = try UserStateObject.create(userId: userId)(realm)
        let states = Observable.from(object: _state).asDriver(onErrorDriveWith: .empty())
        
        self.userId = userId
        self._state = _state
        self.states = states
    }
    
    func on(event: UserStateObject.Event) {
        Realm.backgroundReduce(ofType: UserStateObject.self, forPrimaryKey: userId, event: event)
    }
    
    func userMediaItems() -> Driver<[MediumObject]> {
        guard let items = _state.userMediaState?.cursorMedia?.items else { return .empty() }
        return Observable.collection(from: items)
//            .delaySubscription(0.3, scheduler: MainScheduler.instance)
            .asDriver(onErrorDriveWith: .empty())
            .map { $0.toArray() }
    }
}


