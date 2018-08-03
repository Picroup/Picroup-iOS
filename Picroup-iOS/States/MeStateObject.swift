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

final class MeStateObject: PrimaryObject {
    
    @objc dynamic var version: String?

    @objc dynamic var session: UserSessionObject?
    
    @objc dynamic var selectedTabIndex: Int = 0
    
    @objc dynamic var myMediaState: CursorMediaStateObject?
    
    @objc dynamic var myStaredMediaState: CursorMediaStateObject?

    @objc dynamic var needUpdate: NeedUpdateStateObject?
    
    @objc dynamic var imageDetialRoute: ImageDetialRouteObject?
    @objc dynamic var reputationsRoute: ReputationsRouteObject?
    @objc dynamic var userFollowingsRoute: UserFollowingsRouteObject?
    @objc dynamic var userFollowersRoute: UserFollowersRouteObject?
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
        guard let userId = session?.currentUser?._id else { return nil }
        return myMediaState?.trigger == true
            ? MyMediaQuery(userId: userId, cursor: myMediaState?.cursorMedia?.cursor.value, queryUserId: userId)
            : nil
    }
    var myStaredMediaQuery: MyStaredMediaQuery? {
        guard let userId = session?.currentUser?._id else { return nil }
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
                "myMediaState": CursorMediaStateObject.valuesBy(id: PrimaryKey.myMediaId),
                "myStaredMediaState":  CursorMediaStateObject.valuesBy(id: PrimaryKey.myStaredMediaId),
                "needUpdate": ["_id": _id],
                "imageDetialRoute": ["_id": _id],
                "reputationsRoute": ["_id": _id],
                "userFollowingsRoute": ["_id": _id],
                "userFollowersRoute": ["_id": _id],
                "updateUserRoute": ["_id": _id],
                "feedbackRoute": ["_id": _id],
                "aboutAppRoute": ["_id": _id],
                "popRoute": ["_id": _id],
                ]
            return try realm.update(MeStateObject.self, value: value)
        }
    }
}

extension MeStateObject {
    
    enum Event {
        case onChangeSelectedTab(Tab)
        
        case myMediaState(CursorMediaStateObject.Event)
        case onTriggerReloadMyMediaIfNeeded
        
        case myStaredMediaState(CursorMediaStateObject.Event)
        case onTriggerReloadMyStaredMediaIfNeeded
        
        case onTriggerShowImage(String)
        case onTriggerShowReputations
        case onTriggerShowUserFollowings
        case onTriggerShowUserFollowers
        case onTriggerUpdateUser
        case onTriggerAppFeedback
        case onTriggerAboutApp
        case onTriggerPop
        case onLogout
    }
}

extension MeStateObject: IsFeedbackStateObject {
    
    func reduce(event: Event, realm: Realm) {
        switch event {
        case .onChangeSelectedTab(let tab):
            selectedTabIndex = tab.rawValue
            
        case .myMediaState(let event):
            myMediaState?.reduce(event: event, realm: realm)
        case .onTriggerReloadMyMediaIfNeeded:
            guard needUpdate?.myMedia == true else { return }
            needUpdate?.myMedia = false
            myMediaState?.reduce(event: .onTriggerReload, realm: realm)
            
        case .myStaredMediaState(let event):
            myStaredMediaState?.reduce(event: event, realm: realm)
        case .onTriggerReloadMyStaredMediaIfNeeded:
            guard needUpdate?.myStaredMedia == true else { return }
            needUpdate?.myStaredMedia = false
            myStaredMediaState?.reduce(event: .onTriggerReload, realm: realm)
            
        case .onTriggerShowImage(let mediumId):
            imageDetialRoute?.mediumId = mediumId
            imageDetialRoute?.version = UUID().uuidString
        case .onTriggerShowReputations:
            reputationsRoute?.version = UUID().uuidString
        case .onTriggerShowUserFollowings:
            userFollowingsRoute?.userId = session?.currentUser?._id
            userFollowingsRoute?.version = UUID().uuidString
        case .onTriggerShowUserFollowers:
            userFollowersRoute?.userId = session?.currentUser?._id
            userFollowersRoute?.version = UUID().uuidString
        case .onTriggerUpdateUser:
            updateUserRoute?.version = UUID().uuidString
        case .onTriggerAppFeedback:
            feedbackRoute?.triggerApp()
        case .onTriggerAboutApp:
            aboutAppRoute?.version = UUID().uuidString
        case .onTriggerPop:
            popRoute?.version = UUID().uuidString
        case .onLogout:
            session?.currentUser = nil
            realm.delete(realm.objects(UserObject.self))
            realm.delete(realm.objects(MediumObject.self))
            realm.delete(realm.objects(NotificationObject.self))
            realm.delete(realm.objects(ReputationObject.self))
        }
        version = UUID().uuidString
    }
}

final class MeStateStore {
    
    let states: Driver<MeStateObject>
    private let _state: MeStateObject
    
    init() throws {
        let realm = try Realm()
        let _state = try MeStateObject.create()(realm)
        let states = Observable.from(object: _state).asDriver(onErrorDriveWith: .empty())
        
        self._state = _state
        self.states = states
    }
    
    func on(event: MeStateObject.Event) {
        let id = PrimaryKey.default
        Realm.backgroundReduce(ofType: MeStateObject.self, forPrimaryKey: id, event: event)
    }
    
    func myMediaItems() -> Driver<[MediumObject]> {
        guard let items = _state.myMediaState?.cursorMedia?.items else { return .empty() }
        return Observable.collection(from: items)
//            .delaySubscription(0.3, scheduler: MainScheduler.instance)
            .asDriver(onErrorDriveWith: .empty())
            .map { $0.filter { !$0.isInvalidated } }
    }
    
    func myStaredMediaItems() -> Driver<[MediumObject]> {
        guard let items = _state.myStaredMediaState?.cursorMedia?.items else { return .empty() }
        return Observable.collection(from: items)
//            .delaySubscription(0.3, scheduler: MainScheduler.instance)
            .asDriver(onErrorDriveWith: .empty())
            .map { $0.filter { !$0.isInvalidated } }
    }
}

