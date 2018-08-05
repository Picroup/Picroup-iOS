//
//  UserBlockingsStateObject.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/8/3.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift
import RxCocoa
import RxRealm

final class UserBlockingsStateObject: PrimaryObject {
    
    @objc dynamic var session: UserSessionObject?
    
    let userBlockings = List<UserObject>()
    @objc dynamic var userBlockingsError: String?
    @objc dynamic var triggerUserBlockingsQuery: Bool = false
    
    @objc dynamic var blockingUserId: String?
    @objc dynamic var blockUserError: String?
    @objc dynamic var triggerBlockUserQuery: Bool = false
    
    @objc dynamic var unblockingUserId: String?
    @objc dynamic var unblockUserError: String?
    @objc dynamic var triggerUnblockUserQuery: Bool = false
    
    @objc dynamic var needUpdate: NeedUpdateStateObject?
    
    @objc dynamic var userRoute: UserRouteObject?
}

extension UserBlockingsStateObject {
    var userBlockingsQuery: UserBlockingUsersQuery? {
        guard let userId = session?.currentUserId else { return nil }
        return triggerUserBlockingsQuery
            ? UserBlockingUsersQuery(userId: userId)
            : nil
    }
    var isBlockingsEmpty: Bool {
        return !triggerUserBlockingsQuery && userBlockingsError == nil && userBlockings.isEmpty
    }
    
    var shouldBlockUser: Bool {
        return !triggerBlockUserQuery
    }
    var blockUserQuery: BlockUserMutation? {
        guard let userId = session?.currentUserId,
            let blockingUserId = blockingUserId else { return nil }
        return triggerBlockUserQuery
            ? BlockUserMutation(userId: userId, blockingUserId: blockingUserId)
            : nil
    }
    
    var shouldUnblockUser: Bool {
        return !triggerUnblockUserQuery
    }
    var unblockUserQuery: UnblockUserMutation? {
        guard let userId = session?.currentUserId,
            let unblockingUserId = unblockingUserId else { return nil }
        return triggerUnblockUserQuery
            ? UnblockUserMutation(userId: userId, blockingUserId: unblockingUserId)
            : nil
    }
}

extension UserBlockingsStateObject {
    
    static func create() -> (Realm) throws -> UserBlockingsStateObject {
        return { realm in
            let _id = PrimaryKey.default
            let value: Any = [
                "_id": _id,
                "session": ["_id": _id],
                "userBlockings": [],
                "needUpdate": ["_id": _id],
                "userRoute": ["_id": _id],
                ]
            return try realm.update(UserBlockingsStateObject.self, value: value)
        }
    }
}

extension UserBlockingsStateObject {
    
    enum Event {
        case onTriggerReloadUserBlockings
        case onGetReloadUserFollowings(UserBlockingUsersQuery.Data.User)
        case onGetUserFollowingsError(Error)
        
        case onTriggerBlockUser(String)
        case onBlockUserSuccess(BlockUserMutation.Data.BlockUser)
        case onBlockUserError(Error)
        
        case onTriggerUnblockUser(String)
        case onUnblockUserSuccess(UnblockUserMutation.Data.UnblockUser)
        case onUnblockUserError(Error)
        
        case onTriggerShowUser(String)
    }
}

extension UserBlockingsStateObject: IsFeedbackStateObject {
    
    func reduce(event: Event, realm: Realm) {
        switch event {
        case .onTriggerReloadUserBlockings:
            userBlockingsError = nil
            triggerUserBlockingsQuery = true
        case .onGetReloadUserFollowings(let data):
            {
                userBlockings.removeAll()
                let users: [UserObject] = data.blockingUsers.map {
                    let user = realm.create(UserObject.self, value: $0.snapshot, update: true)
                    user.blocked.value = true
                    return user
                }
                userBlockings.append(objectsIn: users)
            }()
            userBlockingsError = nil
            triggerUserBlockingsQuery = false
        case .onGetUserFollowingsError(let error):
            userBlockingsError = error.localizedDescription
            triggerUserBlockingsQuery = false
            
        case .onTriggerBlockUser(let blockingUserId):
            guard shouldBlockUser else { return }
            self.blockingUserId = blockingUserId
            blockUserError = nil
            triggerBlockUserQuery = true
        case .onBlockUserSuccess(let data):
            let user = realm.create(UserObject.self, value: data.snapshot, update: true)
            user.blocked.value = true
            blockingUserId = nil
            blockUserError = nil
            triggerBlockUserQuery = false
            needUpdate?.myInterestedMedia = true
            needUpdate?.myStaredMedia = true
        case .onBlockUserError(let error):
            blockUserError = error.localizedDescription
            triggerBlockUserQuery = false
            
        case .onTriggerUnblockUser(let toUserId):
            guard shouldUnblockUser else { return }
            unblockingUserId = toUserId
            unblockUserError = nil
            triggerUnblockUserQuery = true
        case .onUnblockUserSuccess(let data):
            let user = realm.create(UserObject.self, value: data.snapshot, update: true)
            user.blocked.value = false
            unblockingUserId = nil
            unblockUserError = nil
            triggerUnblockUserQuery = false
            needUpdate?.myInterestedMedia = true
            needUpdate?.myStaredMedia = true
        case .onUnblockUserError(let error):
            unblockUserError = error.localizedDescription
            triggerUnblockUserQuery = false
            
        case .onTriggerShowUser(let userId):
            userRoute?.userId = userId
            userRoute?.version = UUID().uuidString
        }
    }
}

final class UserBlockingsStateStore {
    
    let states: Driver<UserBlockingsStateObject>
    private let _state: UserBlockingsStateObject
    
    init() throws {
        let realm = try Realm()
        let _state = try UserBlockingsStateObject.create()(realm)
        let states = Observable.from(object: _state).asDriver(onErrorDriveWith: .empty())
        
        self._state = _state
        self.states = states
    }
    
    func on(event: UserBlockingsStateObject.Event) {
        Realm.backgroundReduce(ofType: UserBlockingsStateObject.self, forPrimaryKey: PrimaryKey.default, event: event)
    }
    
    func userBlockingsItems() -> Driver<[UserObject]> {
        return Observable.collection(from: _state.userBlockings)
            //            .delaySubscription(0.3, scheduler: MainScheduler.instance)
            .asDriver(onErrorDriveWith: .empty())
            .map { $0.toArray() }
    }
}


