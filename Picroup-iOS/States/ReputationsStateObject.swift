//
//  ReputationsStateObject.swift
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

final class ReputationsStateObject: PrimaryObject {
    
    @objc dynamic var session: UserSessionObject?
    
    @objc dynamic var reputations: CursorReputationsObject?
    @objc dynamic var reputationsError: String?
    @objc dynamic var triggerReputationsQuery: Bool = false
    
    @objc dynamic var marked: String?
    @objc dynamic var markError: String?
    @objc dynamic var triggerMarkQuery: Bool = false
    
    @objc dynamic var imageDetialRoute: ImageDetialRouteObject?
    @objc dynamic var userRoute: UserRouteObject?
    @objc dynamic var popRoute: PopRouteObject?

}

extension ReputationsStateObject {
    public var reputationsQuery: MyReputationsQuery? {
        guard let userId = session?.currentUser?._id else { return nil }
        let next = MyReputationsQuery(userId: userId, cursor: reputations?.cursor.value)
        return triggerReputationsQuery ? next : nil
    }
    var shouldQueryMoreReputations: Bool {
        return !triggerReputationsQuery && hasMoreReputations
    }
    var isNotificationsEmpty: Bool {
        guard let items = reputations?.items else { return false }
        return !triggerReputationsQuery && reputationsError == nil && items.isEmpty
    }
    var hasMoreReputations: Bool {
        return reputations?.cursor.value != nil
    }
    public var markQuery: MarkReputationLinksAsViewedQuery? {
        guard let userId = session?.currentUser?._id else { return nil }
        let next = MarkReputationLinksAsViewedQuery(userId: userId)
        return triggerMarkQuery && !isNotificationsEmpty ? next : nil
    }
}


extension ReputationsStateObject {
    
    static func create() -> (Realm) throws -> ReputationsStateObject {
        return { realm in
            let _id = PrimaryKey.default
            let value: Any = [
                "_id": _id,
                "session": ["_id": _id],
                "reputations": ["_id": _id],
                "imageDetialRoute": ["_id": _id],
                "userRoute": ["_id": _id],
                "popRoute": ["_id": _id],
                ]
            return try realm.findOrCreate(ReputationsStateObject.self, forPrimaryKey: _id, value: value)
        }
    }
}

extension ReputationsStateObject {
    
    enum Event {
        case onTriggerReload
        case onTriggerGetMore
        case onGetReloadData(CursorReputationLinksFragment)
        case onGetMoreData(CursorReputationLinksFragment)
        case onGetError(Error)
        case onMarkSuccess(String)
        case onMarkError(Error)
        case onTriggerShowImage(String)
        case onTriggerShowUser(String)
        case onTriggerPop
    }
}

extension ReputationsStateObject.Event {
    
    static func onGetData(isReload: Bool) -> (CursorReputationLinksFragment) -> ReputationsStateObject.Event {
        return { isReload ? .onGetReloadData($0) : .onGetMoreData($0) }
    }
}

extension ReputationsStateObject: IsFeedbackStateObject {
    
    func reduce(event: Event, realm: Realm) {
        switch event {
        case .onTriggerReload:
            reputations?.cursor.value = nil
            reputationsError = nil
            triggerReputationsQuery = true
        case .onTriggerGetMore:
            guard shouldQueryMoreReputations else { return }
            reputationsError = nil
            triggerReputationsQuery = true
        case .onGetReloadData(let data):
            reputations = CursorReputationsObject.create(from: data, id: PrimaryKey.default)(realm)
            reputationsError = nil
            triggerReputationsQuery = false
            
            marked = nil
            markError = nil
            triggerMarkQuery = true
        case .onGetMoreData(let data):
            reputations?.merge(from: data)(realm)
            reputationsError = nil
            triggerReputationsQuery = false
        case .onGetError(let error):
            reputationsError = error.localizedDescription
            triggerReputationsQuery = false
            
        case .onMarkSuccess(let id):
            marked = id
            markError = nil
            triggerMarkQuery = false
        case .onMarkError(let error):
            marked = nil
            markError = error.localizedDescription
            triggerMarkQuery = false
            
        case .onTriggerShowImage(let mediumId):
            imageDetialRoute?.mediumId = mediumId
            imageDetialRoute?.version = UUID().uuidString
        case .onTriggerShowUser(let userId):
            userRoute?.userId = userId
            userRoute?.version = UUID().uuidString
        case .onTriggerPop:
            popRoute?.version = UUID().uuidString
        }
    }
}


final class ReputationsStateStore {
    
    let states: Driver<ReputationsStateObject>
    private let _state: ReputationsStateObject
    
    init() throws {
        
        let realm = try Realm()
        let _state = try ReputationsStateObject.create()(realm)
        let states = Observable.from(object: _state).asDriver(onErrorDriveWith: .empty())
        
        self._state = _state
        self.states = states
    }
    
    func on(event: ReputationsStateObject.Event) {
        let id = PrimaryKey.default
        Realm.backgroundReduce(ofType: ReputationsStateObject.self, forPrimaryKey: id, event: event)
    }
    
    func reputations() -> Driver<[ReputationObject]> {
        guard let items = _state.reputations?.items else { return .empty() }
        return Observable.collection(from: items)
            .asDriver(onErrorDriveWith: .empty())
            .map { $0.toArray() }
    }
}


