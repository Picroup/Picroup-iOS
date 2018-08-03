//
//  AppState.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/20.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxFeedback
import RealmSwift
import RxRealm

final class UserSessionObject: PrimaryObject {
    @objc dynamic var currentUser: UserObject?
}

extension UserSessionObject {
    var isLogin: Bool {
        return currentUser != nil
    }
    var currentUserId: String? {
        return currentUser?._id
    }
}

final class AppStateObject: PrimaryObject {
    
    @objc dynamic var session: UserSessionObject?
    
    @objc dynamic var meError: String?
    @objc dynamic var triggerMeQuery: Bool = false
    
    @objc dynamic var previousMediumId: String?
    @objc dynamic var currentMediumId: String?
    @objc dynamic var triggerRecommendMedium = false
}

extension AppStateObject {
    var meQuery: UserQuery? {
        guard let userId = session?.currentUser?._id else { return nil }
        let next = UserQuery(userId: userId, followedByUserId: "", withFollowed: false)
        return triggerMeQuery ? next : nil
    }
    var me: UserObject? {
        return session?.currentUser
    }
    
    var recommendMediumQuery: RecommendMediumMutation? {
        guard
            let previousMediumId = previousMediumId,
            let currentMediumId = currentMediumId,
            previousMediumId != currentMediumId  else {
                return nil
        }
        let query = RecommendMediumMutation(mediumId: previousMediumId, recommendMediumId: currentMediumId)
        return triggerRecommendMedium ? query : nil
    }
}

extension AppStateObject {
    
    static func create() -> (Realm) throws -> AppStateObject {
        return { realm in
            let _id = PrimaryKey.default
            let value: Any = [
                "_id": _id,
                "session": ["_id": _id],
                ]
            return try realm.update(AppStateObject.self, value: value)
        }
    }
}

extension AppStateObject {
    
    enum Event {
        case onTriggerReloadMe
        case onGetMeSuccess(UserDetailFragment)
        case onGetMeError(Error)
        case onViewMedium(String)
        case onRecommendMediumCompleted
    }
}

extension AppStateObject: IsFeedbackStateObject {
    
    func reduce(event: Event, realm: Realm) {
        switch event {
        case .onTriggerReloadMe:
            meError = nil
            triggerMeQuery = true
        case .onGetMeSuccess(let data):
            guard session?.isLogin == true else { return }
            session?.currentUser = UserObject.create(from: data)(realm)
            meError = nil
            triggerMeQuery = false
        case .onGetMeError(let error):
            meError = error.localizedDescription
            triggerMeQuery = false
            
        case .onViewMedium(let mediumId):
            previousMediumId = currentMediumId
            currentMediumId = mediumId
            triggerRecommendMedium = true
        case  .onRecommendMediumCompleted:
            triggerRecommendMedium = false
        }
    }
}

final class AppStateStore {
    
    let states: Driver<AppStateObject>
    private let _state: AppStateObject
    
    init() throws {
        let realm = try Realm()
        let _state = try AppStateObject.create()(realm)
        let states = Observable.from(object: _state).asDriver(onErrorDriveWith: .empty())
        
        self._state = _state
        self.states = states
    }
    
    func on(event: AppStateObject.Event) {
        let _id = PrimaryKey.default
        Realm.backgroundReduce(ofType: AppStateObject.self, forPrimaryKey: _id, event: event)
    }
    
    func me() -> Driver<UserObject> {
        guard let me = _state.session?.currentUser else { return .empty() }
        return Observable.from(object: me).asDriver(onErrorDriveWith: .empty())
    }
}


