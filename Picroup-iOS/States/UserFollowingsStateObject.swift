//
//  UserFollowingsStateObject.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/21.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift
import RxCocoa
import RxRealm

final class UserFollowingsStateObject: PrimaryObject {
    
    @objc dynamic var session: UserSessionObject?
    
    @objc dynamic var user: UserObject?
    
    @objc dynamic var userFollowings: CursorUsersObject?
    @objc dynamic var userFollowingsError: String?
    @objc dynamic var triggerUserFollowingsQuery: Bool = false
    
    @objc dynamic var popRoute: PopRouteObject?
}

extension UserFollowingsStateObject {
    var userId: String { return _id }
    var userFollowingsQuery: UserFollowingsQuery? {
        guard let byUserId = session?.currentUser?._id else {
            return nil
        }
        let next = UserFollowingsQuery(userId: userId, followedByUserId: byUserId, cursor: userFollowings?.cursor.value)
        return triggerUserFollowingsQuery ? next : nil
    }
    var shouldQueryMoreUserFollowings: Bool {
        return !triggerUserFollowingsQuery && hasMoreUserFollowings
    }
    var hasMoreUserFollowings: Bool {
        return userFollowings?.cursor.value != nil
    }
}

extension UserFollowingsStateObject {
    
    static func create(userId: String) -> (Realm) throws -> UserFollowingsStateObject {
        return { realm in
            let _id = PrimaryKey.default
            let value: Any = [
                "_id": userId,
                "session": ["_id": _id],
                "user": ["_id": userId],
                "userFollowings": ["_id": PrimaryKey.userFollowingsId(userId)],
                "popRoute": ["_id": _id],
                ]
            return try realm.findOrCreate(UserFollowingsStateObject.self, forPrimaryKey: userId, value: value)
        }
    }
}

extension UserFollowingsStateObject {
    
    enum Event {
        case onTriggerReloadUserFollowings
        case onTriggerGetMoreUserFollowings
        case onGetReloadUserFollowings(UserFollowingsQuery.Data.User.Following)
        case onGetMoreUserFollowings(UserFollowingsQuery.Data.User.Following)
        case onGetUserFollowingsError(Error)
        case onTriggerPop
    }
}

extension UserFollowingsStateObject.Event {
    
    static func onGetUserFollowings(isReload: Bool) -> (UserFollowingsQuery.Data.User.Following) -> UserFollowingsStateObject.Event {
        return { isReload ? .onGetReloadUserFollowings($0) : .onGetMoreUserFollowings($0) }
    }
}

extension UserFollowingsStateObject: IsFeedbackStateObject {
    
    func reduce(event: Event, realm: Realm) {
        switch event {
        case .onTriggerReloadUserFollowings:
            userFollowings?.cursor.value = nil
            userFollowingsError = nil
            triggerUserFollowingsQuery = true
        case .onTriggerGetMoreUserFollowings:
            guard shouldQueryMoreUserFollowings else { return }
            userFollowingsError = nil
            triggerUserFollowingsQuery = true
        case .onGetReloadUserFollowings(let data):
            userFollowings = CursorUsersObject.create(from: data, id: PrimaryKey.userFollowingsId(userId))(realm)
            userFollowingsError = nil
            triggerUserFollowingsQuery = false
        case .onGetMoreUserFollowings(let data):
            userFollowings?.merge(from: data)(realm)
            userFollowingsError = nil
            triggerUserFollowingsQuery = false
        case .onGetUserFollowingsError(let error):
            userFollowingsError = error.localizedDescription
            triggerUserFollowingsQuery = false
        case .onTriggerPop:
            popRoute?.version = UUID().uuidString
        }
    }
}

final class UserFollowingsStateStore {
    
    let states: Driver<UserFollowingsStateObject>
    private let _state: UserFollowingsStateObject
    private let userId: String
    
    init(userId: String) throws {
        let realm = try Realm()
        let _state = try UserFollowingsStateObject.create(userId: userId)(realm)
        let states = Observable.from(object: _state).asDriver(onErrorDriveWith: .empty())
        
        self.userId = userId
        self._state = _state
        self.states = states
    }
    
    func on(event: UserFollowingsStateObject.Event) {
        Realm.backgroundReduce(ofType: UserFollowingsStateObject.self, forPrimaryKey: userId, event: event)
    }
    
    func userFollowingsItems() -> Driver<[UserObject]> {
        guard let items = _state.userFollowings?.items else { return .empty() }
        return Observable.collection(from: items)
            .delaySubscription(0.3, scheduler: MainScheduler.instance)
            .asDriver(onErrorDriveWith: .empty())
            .map { $0.toArray() }
    }
}


