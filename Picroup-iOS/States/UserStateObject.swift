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
    
    @objc dynamic var session: UserSessionObject?
    
    @objc dynamic var user: UserObject?
    @objc dynamic var userError: String?
    @objc dynamic var triggerUserQuery: Bool = false
    
    @objc dynamic var userMedia: CursorMediaObject?
    @objc dynamic var userMediaError: String?
    @objc dynamic var triggerUserMediaQuery: Bool = false
    
    @objc dynamic var imageDetialRoute: ImageDetialRouteObject?
    @objc dynamic var popRoute: PopRouteObject?
}

extension UserStateObject {
    var userId: String { return _id }
    var userQuery: UserQuery? {
        let next = UserQuery(userId: userId)
        return triggerUserQuery ? next : nil
    }
    var userMediaQuery: MyMediaQuery? {
        let next = MyMediaQuery(userId: userId, cursor: userMedia?.cursor.value)
        return triggerUserMediaQuery ? next : nil
    }
    var shouldQueryMoreUserMedia: Bool {
        return !triggerUserMediaQuery && hasMoreMyMedia
    }
    var hasMoreMyMedia: Bool {
        return userMedia?.cursor.value != nil
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
                "userMedia": ["_id": PrimaryKey.userMediaId(userId)],
                "imageDetialRoute": ["_id": _id],
                "popRoute": ["_id": _id],
                ]
            return try realm.findOrCreate(UserStateObject.self, forPrimaryKey: userId, value: value)
        }
    }
}

extension UserStateObject {
    
    enum Event {
        case onTriggerReloadUser
        case onGetUserSuccess(UserDetailFragment)
        case onGetUserError(Error)
        
        case onTriggerReloadUserMedia
        case onTriggerGetMoreUserMedia
        case onGetReloadUserMedia(CursorMediaFragment)
        case onGetMoreUserMedia(CursorMediaFragment)
        case onGetUserMediaError(Error)
        
        case onTriggerShowImage(String)
        case onTriggerPop
    }
}

extension UserStateObject.Event {
    
    static func onGetUserMedia(isReload: Bool) -> (CursorMediaFragment) -> UserStateObject.Event {
        return { isReload ? .onGetReloadUserMedia($0) : .onGetMoreUserMedia($0) }
    }
}

extension UserStateObject: IsFeedbackStateObject {
    
    func reduce(event: Event, realm: Realm) {
        switch event {
        case .onTriggerReloadUser:
            userError = nil
            triggerUserQuery = true
        case .onGetUserSuccess(let data):
            user = UserObject.create(from: data)(realm)
            userError = nil
            triggerUserQuery = false
        case .onGetUserError(let error):
            userError = error.localizedDescription
            triggerUserQuery = false
            
        case .onTriggerReloadUserMedia:
            userMedia?.cursor.value = nil
            userMediaError = nil
            triggerUserMediaQuery = true
        case .onTriggerGetMoreUserMedia:
            guard shouldQueryMoreUserMedia else { return }
            userMedia = nil
            triggerUserMediaQuery = true
        case .onGetReloadUserMedia(let data):
            userMedia = CursorMediaObject.create(from: data, id: PrimaryKey.userMediaId(userId))(realm)
            userMediaError = nil
            triggerUserMediaQuery = false
        case .onGetMoreUserMedia(let data):
            userMedia?.merge(from: data)(realm)
            userMediaError = nil
            triggerUserMediaQuery = false
        case .onGetUserMediaError(let error):
            userMediaError = error.localizedDescription
            triggerUserMediaQuery = false
            
        case .onTriggerShowImage(let mediumId):
            imageDetialRoute?.mediumId = mediumId
            imageDetialRoute?.version = UUID().uuidString
        case .onTriggerPop:
            popRoute?.version = UUID().uuidString
        }
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
        guard let items = _state.userMedia?.items else { return .empty() }
        return Observable.collection(from: items)
            .delaySubscription(0.3, scheduler: MainScheduler.instance)
            .asDriver(onErrorDriveWith: .empty())
            .map { $0.toArray() }
    }
}


