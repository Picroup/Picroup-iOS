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

class RankStateObject: PrimaryObject {
    
    @objc dynamic var rankMedia: CursorMediaObject?
    @objc dynamic var rankedMediaError: String?
    @objc dynamic var triggerRankedMediaQuery: Bool = false
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
        return { realm in
            let _id = Config.realmDefaultPrimaryKey
            let value: Any = [
                "_id": _id,
                "rankMedia": ["_id": "rankMedia"]
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
    }
}

extension RankStateObject.Event {
    
    static func onGetData(isReload: Bool) -> (CursorMediaFragment) -> RankStateObject.Event {
        return { isReload ? .onGetReloadData($0) : .onGetMoreData($0) }
    }
}

extension RankStateObject {
    
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
            rankMedia = CursorMediaObject.create(from: data, id: "rankMedia")(realm)
            rankedMediaError = nil
            triggerRankedMediaQuery = false
        case .onGetMoreData(let data):
            rankMedia?.merge(from: data)(realm)
            rankedMediaError = nil
            triggerRankedMediaQuery = false
        case .onGetError(let error):
            rankedMediaError = error.localizedDescription
            triggerRankedMediaQuery = false
        }
    }
}

class RankStateStore {
    
    let states: Driver<RankStateObject>
    private let _state: RankStateObject
    
    init() throws {
        let realm = try Realm()
        let _state = try RankStateObject.create()(realm)
        let states = Observable.from(object: _state).asDriver(onErrorDriveWith: .empty())
        
        self._state = _state
        self.states = states
    }
    
    func on(event: RankStateObject.Event) -> () {
        Realm.background(updates: { realm in
            guard let state = realm.object(ofType: RankStateObject.self, forPrimaryKey: Config.realmDefaultPrimaryKey) else {
                print("error: RankStateObject is lost")
                return
            }
            try realm.write {
                state.reduce(event: event, realm: realm)
            }
        }, onError: { error in
            print("realm error:", error)
        })
    }
    
    func rankMediaItems() -> Driver<List<MediumObject>> {
        guard let items = _state.rankMedia?.items else { return .empty() }
        return Observable.collection(from: items).asDriver(onErrorDriveWith: .empty())
    }
}

