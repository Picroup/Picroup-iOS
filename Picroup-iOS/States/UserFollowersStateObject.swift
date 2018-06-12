//
//  UserFollowersStateObject.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/22.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift
import RxCocoa
import RxRealm

final class UserFollowersStateObject: PrimaryObject {
    
    @objc dynamic var session: UserSessionObject?
    
    @objc dynamic var user: UserObject?
    
    @objc dynamic var userFollowers: CursorUsersObject?
    @objc dynamic var userFollowersError: String?
    @objc dynamic var triggerUserFollowersQuery: Bool = false
    
    @objc dynamic var followToUserId: String?
    @objc dynamic var followUserError: String?
    @objc dynamic var triggerFollowUserQuery: Bool = false
    
    @objc dynamic var unfollowToUserId: String?
    @objc dynamic var unfollowUserError: String?
    @objc dynamic var triggerUnfollowUserQuery: Bool = false
    
    @objc dynamic var needUpdate: NeedUpdateStateObject?
    
    @objc dynamic var userRoute: UserRouteObject?
    @objc dynamic var popRoute: PopRouteObject?
}

extension UserFollowersStateObject {
    var userId: String { return _id }
    var userFollowersQuery: UserFollowersQuery? {
        let (byUserId, withFollowed) = session?.currentUser?._id == nil
            ? ("", false)
            : (session!.currentUser!._id, true)
        let next = UserFollowersQuery(userId: userId, followedByUserId: byUserId, cursor: userFollowers?.cursor.value, withFollowed: withFollowed)
        return triggerUserFollowersQuery ? next : nil
    }
    var shouldQueryMoreUserFollowers: Bool {
        return !triggerUserFollowersQuery && hasMoreUserFollowers
    }
    var isFollowersEmpty: Bool {
        guard let items = userFollowers?.items else { return false }
        return !triggerUserFollowersQuery && userFollowersError == nil && items.isEmpty
    }
    var hasMoreUserFollowers: Bool {
        return userFollowers?.cursor.value != nil
    }
    
    var shouldFollowUser: Bool {
        return !triggerFollowUserQuery
    }
    var followUserQuery: FollowUserMutation? {
        guard
            let userId = session?.currentUser?._id,
            let toUserId = followToUserId else {
                return nil
        }
        return triggerFollowUserQuery ? FollowUserMutation(userId: userId, toUserId: toUserId) : nil
    }
    
    var shouldUnfollowUser: Bool {
        return !triggerUnfollowUserQuery
    }
    var unfollowUserQuery: UnfollowUserMutation? {
        guard
            let userId = session?.currentUser?._id,
            let toUserId = unfollowToUserId else {
                return nil
        }
        return triggerUnfollowUserQuery ? UnfollowUserMutation(userId: userId, toUserId: toUserId) : nil
    }
}

extension UserFollowersStateObject {
    
    static func create(userId: String) -> (Realm) throws -> UserFollowersStateObject {
        return { realm in
            let _id = PrimaryKey.default
            let value: Any = [
                "_id": userId,
                "session": ["_id": _id],
                "user": ["_id": userId],
                "userFollowers": ["_id": PrimaryKey.userFollowersId(userId)],
                "needUpdate": ["_id": _id],
                "userRoute": ["_id": _id],
                "popRoute": ["_id": _id],
                ]
            return try realm.update(UserFollowersStateObject.self, value: value)
        }
    }
}

extension UserFollowersStateObject {
    
    enum Event {
        case onTriggerReloadUserFollowers
        case onTriggerGetMoreUserFollowers
        case onGetReloadUserFollowers(UserFollowersQuery.Data.User.Follower)
        case onGetMoreUserFollowers(UserFollowersQuery.Data.User.Follower)
        case onGetUserFollowersError(Error)
        
        case onTriggerFollowUser(String)
        case onFollowUserSuccess(FollowUserMutation.Data.FollowUser)
        case onFollowUserError(Error)
        
        case onTriggerUnfollowUser(String)
        case onUnfollowUserSuccess(UnfollowUserMutation.Data.UnfollowUser)
        case onUnfollowUserError(Error)
        
        case onTriggerShowUser(String)
        case onTriggerPop
    }
}

extension UserFollowersStateObject.Event {
    
    static func onGetUserFollowers(isReload: Bool) -> (UserFollowersQuery.Data.User.Follower) -> UserFollowersStateObject.Event {
        return { isReload ? .onGetReloadUserFollowers($0) : .onGetMoreUserFollowers($0) }
    }
}

extension UserFollowersStateObject: IsFeedbackStateObject {
    
    func reduce(event: Event, realm: Realm) {
        switch event {
        case .onTriggerReloadUserFollowers:
            userFollowers?.cursor.value = nil
            userFollowersError = nil
            triggerUserFollowersQuery = true
        case .onTriggerGetMoreUserFollowers:
            guard shouldQueryMoreUserFollowers else { return }
            userFollowersError = nil
            triggerUserFollowersQuery = true
        case .onGetReloadUserFollowers(let data):
            userFollowers = CursorUsersObject.create(from: data, id: PrimaryKey.userFollowersId(userId))(realm)
            userFollowersError = nil
            triggerUserFollowersQuery = false
        case .onGetMoreUserFollowers(let data):
            userFollowers?.merge(from: data)(realm)
            userFollowersError = nil
            triggerUserFollowersQuery = false
        case .onGetUserFollowersError(let error):
            userFollowersError = error.localizedDescription
            triggerUserFollowersQuery = false
            
        case .onTriggerFollowUser(let toUserId):
            guard shouldFollowUser else { return }
            followToUserId = toUserId
            followUserError = nil
            triggerFollowUserQuery = true
        case .onFollowUserSuccess(let data):
            realm.create(UserObject.self, value: data.snapshot, update: true)
            followToUserId = nil
            followUserError = nil
            triggerFollowUserQuery = false
            needUpdate?.myInterestedMedia = true

        case .onFollowUserError(let error):
            followUserError = error.localizedDescription
            triggerFollowUserQuery = false
            
        case .onTriggerUnfollowUser(let toUserId):
            guard shouldUnfollowUser else { return }
            unfollowToUserId = toUserId
            unfollowUserError = nil
            triggerUnfollowUserQuery = true
        case .onUnfollowUserSuccess(let data):
            realm.create(UserObject.self, value: data.snapshot, update: true)
            unfollowToUserId = nil
            unfollowUserError = nil
            triggerUnfollowUserQuery = false
            needUpdate?.myInterestedMedia = true

        case .onUnfollowUserError(let error):
            unfollowUserError = error.localizedDescription
            triggerUnfollowUserQuery = false
            
        case .onTriggerShowUser(let userId):
            userRoute?.userId = userId
            userRoute?.version = UUID().uuidString
        case .onTriggerPop:
            popRoute?.version = UUID().uuidString
        }
    }
}

final class UserFollowersStateStore {
    
    let states: Driver<UserFollowersStateObject>
    private let _state: UserFollowersStateObject
    private let userId: String
    
    init(userId: String) throws {
        let realm = try Realm()
        let _state = try UserFollowersStateObject.create(userId: userId)(realm)
        let states = Observable.from(object: _state).asDriver(onErrorDriveWith: .empty())
        
        self.userId = userId
        self._state = _state
        self.states = states
    }
    
    func on(event: UserFollowersStateObject.Event) {
        Realm.backgroundReduce(ofType: UserFollowersStateObject.self, forPrimaryKey: userId, event: event)
    }
    
    func userFollowersItems() -> Driver<[UserObject]> {
        guard let items = _state.userFollowers?.items else { return .empty() }
        return Observable.collection(from: items)
//            .delaySubscription(0.3, scheduler: MainScheduler.instance)
            .asDriver(onErrorDriveWith: .empty())
            .map { $0.toArray() }
    }
}


