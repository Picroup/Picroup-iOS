//
//  RankStateService.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/14.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift
import RxCocoa
import RxRealm

final class RankStateObject: PrimaryObject {
    
    @objc dynamic var session: UserSessionObject?

    @objc dynamic var rankMedia: CursorMediaObject?
    @objc dynamic var rankedMediaError: String?
    @objc dynamic var triggerRankedMediaQuery: Bool = false
    
    @objc dynamic var imageDetialRoute: ImageDetialRouteObject?
}

extension RankStateObject {
    var rankedMediaQuery: RankedMediaQuery? {
        let next = RankedMediaQuery(rankBy: nil, cursor: rankMedia?.cursor.value)
        return triggerRankedMediaQuery ? next : nil
    }
    var shouldQueryMoreRankedMedia: Bool {
        return !triggerRankedMediaQuery && hasMoreRankedMedia
    }
    var isRankedMediaEmpty: Bool {
        guard let items = rankMedia?.items else { return false }
        return !triggerRankedMediaQuery && rankedMediaError == nil && items.isEmpty
    }
    var hasMoreRankedMedia: Bool {
        return rankMedia?.cursor.value != nil
    }
    var isReloading: Bool {
        return rankMedia?.cursor.value == nil && triggerRankedMediaQuery
    }
}

extension RankStateObject {
    
    static func create() -> (Realm) throws -> RankStateObject {
        let rankMediaId = PrimaryKey.rankMediaId
        return { realm in
            let _id = PrimaryKey.default
            let value: Any = [
                "_id": _id,
                "session": ["_id": _id],
                "rankMedia": ["_id": rankMediaId],
                "imageDetialRoute": ["_id": _id],
                ]
            return try realm.findOrCreate(RankStateObject.self, forPrimaryKey: _id, value: value)
        }
    }
}

extension RankStateObject {
    
    enum Event {
        case onTriggerReload
        case onTriggerGetMore
        case onGetReloadData(CursorMediaFragment)
        case onGetMoreData(CursorMediaFragment)
        case onGetError(Error)
        case onTriggerShowImage(String)
        case onLogout
    }
}

extension RankStateObject.Event {
    
    static func onGetData(isReload: Bool) -> (CursorMediaFragment) -> RankStateObject.Event {
        return { isReload ? .onGetReloadData($0) : .onGetMoreData($0) }
    }
}

extension RankStateObject: IsFeedbackStateObject {
    
    func reduce(event: Event, realm: Realm) {
        switch event {
        case .onTriggerReload:
            rankMedia?.cursor.value = nil
            rankedMediaError = nil
            triggerRankedMediaQuery = true
        case .onTriggerGetMore:
            guard shouldQueryMoreRankedMedia else { return }
            rankedMediaError = nil
            triggerRankedMediaQuery = true
        case .onGetReloadData(let data):
            rankMedia = CursorMediaObject.create(from: data, id: PrimaryKey.rankMediaId)(realm)
            rankedMediaError = nil
            triggerRankedMediaQuery = false
        case .onGetMoreData(let data):
            rankMedia?.merge(from: data)(realm)
            rankedMediaError = nil
            triggerRankedMediaQuery = false
        case .onGetError(let error):
            rankedMediaError = error.localizedDescription
            triggerRankedMediaQuery = false
        case .onTriggerShowImage(let mediumId):
            imageDetialRoute?.mediumId = mediumId
            imageDetialRoute?.version = UUID().uuidString
        case .onLogout:
            session?.currentUser = nil
        }
    }
}

final class RankStateStore {
    
    let states: Driver<RankStateObject>
    private let _state: RankStateObject
    
    init() throws {
        let realm = try Realm()
        let _state = try RankStateObject.create()(realm)
        let states = Observable.from(object: _state).asDriver(onErrorDriveWith: .empty())
        
        self._state = _state
        self.states = states
    }
    
    func on(event: RankStateObject.Event) {
        let id = PrimaryKey.default
        Realm.backgroundReduce(ofType: RankStateObject.self, forPrimaryKey: id, event: event)
    }
    
    func rankMediaItems() -> Driver<[MediumObject]> {
        guard let items = _state.rankMedia?.items else { return .empty() }
        return Observable.collection(from: items)
            .delaySubscription(0.3, scheduler: MainScheduler.instance)
            .asDriver(onErrorDriveWith: .empty())
            .map { $0.toArray() }
    }
}

