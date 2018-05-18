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
    
    @objc dynamic var session: UserSessionObject?
    
    @objc dynamic var meError: String?
    @objc dynamic var triggerMeQuery: Bool = false
    
    @objc dynamic var selectedTabIndex: Int = 0
    
    @objc dynamic var myMedia: CursorMediaObject?
    @objc dynamic var myMediaError: String?
    @objc dynamic var triggerMyMediaQuery: Bool = false
    
    @objc dynamic var myStaredMedia: CursorMediaObject?
    @objc dynamic var myStaredMediaError: String?
    @objc dynamic var triggerMyStaredMediaQuery: Bool = false
    
    @objc dynamic var imageDetialRoute: ImageDetialRouteObject?
    @objc dynamic var reputationsRoute: ReputationsRouteObject?
    @objc dynamic var popRoute: PopRouteObject?
}

extension MeStateObject {
    
    enum Tab: Int {
        case myMedia
        case myStaredMedia
    }
}

extension MeStateObject {
    var meQuery: UserQuery? {
        guard let userId = session?.currentUser?._id else { return nil }
        let next = UserQuery(userId: userId)
        return triggerMeQuery ? next : nil
    }
    var me: UserObject? {
        return session?.currentUser
    }
    var myMediaQuery: MyMediaQuery? {
        guard let userId = session?.currentUser?._id else { return nil }
        let next = MyMediaQuery(userId: userId, cursor: myMedia?.cursor.value)
        return triggerMyMediaQuery ? next : nil
    }
    var shouldQueryMoreMyMedia: Bool {
        return !triggerMyMediaQuery && hasMoreMyMedia
    }
    var hasMoreMyMedia: Bool {
        return myMedia?.cursor.value != nil
    }
    var myStaredMediaQuery: MyStaredMediaQuery? {
        guard let userId = session?.currentUser?._id else { return nil }
        let next = MyStaredMediaQuery(userId: userId, cursor: myStaredMedia?.cursor.value)
        return triggerMyStaredMediaQuery ? next : nil
    }
    var shouldQueryMoreMyStaredMedia: Bool {
        return !triggerMyStaredMediaQuery && hasMoreMyStaredMedia
    }
    var hasMoreMyStaredMedia: Bool {
        return myStaredMedia?.cursor.value != nil
    }
}

extension MeStateObject {
    
    static func create() -> (Realm) throws -> MeStateObject {
        return { realm in
            let _id = PrimaryKey.default
            let value: Any = [
                "_id": _id,
                "session": ["_id": _id],
                "myMedia": ["_id": PrimaryKey.myMediaId],
                "myStaredMedia": ["_id": PrimaryKey.myStaredMediaId],
                "imageDetialRoute": ["_id": _id],
                "reputationsRoute": ["_id": _id],
                "popRoute": ["_id": _id],
                ]
            return try realm.findOrCreate(MeStateObject.self, forPrimaryKey: _id, value: value)
        }
    }
}

extension MeStateObject {
    
    enum Event {
        case onTriggerReloadMe
        case onGetMeSuccess(UserDetailFragment)
        case onGetMeError(Error)
        
        case onChangeSelectedTab(Tab)
        
        case onTriggerReloadMyMedia
        case onTriggerGetMoreMyMedia
        case onGetReloadMyMedia(CursorMediaFragment)
        case onGetMoreMyMedia(CursorMediaFragment)
        case onGetMyMediaError(Error)
        
        case onTriggerReloadMyStaredMedia
        case onTriggerGetMoreMyStaredMedia
        case onGetReloadMyStaredMedia(CursorMediaFragment)
        case onGetMoreMyStaredMedia(CursorMediaFragment)
        case onGetMyStaredMediaError(Error)
        
        case onTriggerShowImage(String)
        case onTriggerShowReputations
        case onTriggerPop
    }
}

extension MeStateObject.Event {
    
    static func onGetMyMedia(isReload: Bool) -> (CursorMediaFragment) -> MeStateObject.Event {
        return { isReload ? .onGetReloadMyMedia($0) : .onGetMoreMyMedia($0) }
    }
    
    static func onGetMyStaredMedia(isReload: Bool) -> (CursorMediaFragment) -> MeStateObject.Event {
        return { isReload ? .onGetReloadMyStaredMedia($0) : .onGetMoreMyStaredMedia($0) }
    }
}

extension MeStateObject: IsFeedbackStateObject {
    
    func reduce(event: Event, realm: Realm) {
        switch event {
        case .onTriggerReloadMe:
            meError = nil
            triggerMeQuery = true
        case .onGetMeSuccess(let data):
            session?.currentUser = UserObject.create(from: data)(realm)
            meError = nil
            triggerMeQuery = false
        case .onGetMeError(let error):
            meError = error.localizedDescription
            triggerMeQuery = false
            
        case .onChangeSelectedTab(let tab):
            selectedTabIndex = tab.rawValue
            
        case .onTriggerReloadMyMedia:
            myMedia?.cursor.value = nil
            myMediaError = nil
            triggerMyMediaQuery = true
        case .onTriggerGetMoreMyMedia:
            guard shouldQueryMoreMyMedia else { return }
            myMediaError = nil
            triggerMyMediaQuery = true
        case .onGetReloadMyMedia(let data):
            myMedia = CursorMediaObject.create(from: data, id: PrimaryKey.myMediaId)(realm)
            myMediaError = nil
            triggerMyMediaQuery = false
        case .onGetMoreMyMedia(let data):
            myMedia?.merge(from: data)(realm)
            myMediaError = nil
            triggerMyMediaQuery = false
        case .onGetMyMediaError(let error):
            myMediaError = error.localizedDescription
            triggerMyMediaQuery = false
            
        case .onTriggerReloadMyStaredMedia:
            myStaredMedia?.cursor.value = nil
            myStaredMediaError = nil
            triggerMyStaredMediaQuery = true
        case .onTriggerGetMoreMyStaredMedia:
            guard shouldQueryMoreMyStaredMedia else { return }
            myStaredMediaError = nil
            triggerMyStaredMediaQuery = true
        case .onGetReloadMyStaredMedia(let data):
            myStaredMedia = CursorMediaObject.create(from: data, id: PrimaryKey.myStaredMediaId)(realm)
            myStaredMediaError = nil
            triggerMyStaredMediaQuery = false
        case .onGetMoreMyStaredMedia(let data):
            myStaredMedia?.merge(from: data)(realm)
            myStaredMediaError = nil
            triggerMyStaredMediaQuery = false
        case .onGetMyStaredMediaError(let error):
            myStaredMediaError = error.localizedDescription
            triggerMyStaredMediaQuery = false
            
        case .onTriggerShowImage(let mediumId):
            imageDetialRoute?.mediumId = mediumId
            imageDetialRoute?.version = UUID().uuidString
        case .onTriggerShowReputations:
            reputationsRoute?.version = UUID().uuidString
        case .onTriggerPop:
            popRoute?.version = UUID().uuidString
        }
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
        guard let items = _state.myMedia?.items else { return .empty() }
        return Observable.collection(from: items)
            .delaySubscription(0.3, scheduler: MainScheduler.instance)
            .asDriver(onErrorDriveWith: .empty())
            .map { $0.toArray() }
    }
    
    func myStaredMediaItems() -> Driver<[MediumObject]> {
        guard let items = _state.myStaredMedia?.items else { return .empty() }
        return Observable.collection(from: items)
            .delaySubscription(0.3, scheduler: MainScheduler.instance)
            .asDriver(onErrorDriveWith: .empty())
            .map { $0.toArray() }
    }
}

