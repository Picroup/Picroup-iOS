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

final class AppStateObject0: PrimaryObject {
    
    @objc dynamic var session: UserSessionObject?
    
    @objc dynamic var previousMediumId: String?
    @objc dynamic var currentMediumId: String?
    @objc dynamic var triggerRecommendMedium = false
}

extension AppStateObject0 {
    
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

extension AppStateObject0 {
    
    static func create() -> (Realm) throws -> AppStateObject0 {
        return { realm in
            let _id = PrimaryKey.default
            let value: Any = [
                "_id": _id,
                "session": ["_id": _id],
                ]
            return try realm.findOrCreate(AppStateObject0.self, forPrimaryKey: _id, value: value)
        }
    }
}

extension AppStateObject0 {
    
    enum Event {
        case onViewMedium(String)
        case onRecommendMediumCompleted
    }
}

extension AppStateObject0: IsFeedbackStateObject {
    
    func reduce(event: Event, realm: Realm) {
        switch event {
        case .onViewMedium(let mediumId):
            previousMediumId = currentMediumId
            currentMediumId = mediumId
            triggerRecommendMedium = true
        case  .onRecommendMediumCompleted:
            triggerRecommendMedium = false
        }
    }
}

final class AppStateStore0 {
    
    let states: Driver<AppStateObject0>
    private let _state: AppStateObject0
    
    init() throws {
        let realm = try Realm()
        let _state = try AppStateObject0.create()(realm)
        let states = Observable.from(object: _state).asDriver(onErrorDriveWith: .empty())
        
        self._state = _state
        self.states = states
    }
    
    func on(event: AppStateObject0.Event) {
        let _id = PrimaryKey.default
        Realm.backgroundReduce(ofType: AppStateObject0.self, forPrimaryKey: _id, event: event)
    }
}


