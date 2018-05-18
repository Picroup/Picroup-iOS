//
//  AppStore.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/8.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxFeedback
import RealmSwift
import RxRealm

final class AppStateObject: Object {
    @objc dynamic var _id: String?
    @objc dynamic var currentUser: UserObject?
    
    @objc dynamic var session: UserSessionObject?
    
    @objc dynamic var previousMediumId: String?
    @objc dynamic var currentMediumId: String?
    @objc dynamic var triggerRecommendMedium = false

    override static func primaryKey() -> String {
        return "_id"
    }
}

extension AppStateObject {
    
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
    fileprivate static let appPrimaryKey = "current"
    static let shared: AppStateObject = {
        let realm = try! Realm()
        if let result = realm.object(ofType: AppStateObject.self, forPrimaryKey: AppStateObject.appPrimaryKey) {
            return result
        }
        let result = AppStateObject()
        result._id = AppStateObject.appPrimaryKey
        try? realm.write {
            realm.add(result, update: true)
            result.session = realm.create(UserSessionObject.self, value: ["_id": PrimaryKey.default], update: true)
        }
        return result
    }()
}

final class AppStore {
    
    lazy var state = Observable.from(object: AppStateObject.shared).asDriver(onErrorDriveWith: .empty())
    
    func onLogin(_ value: [String: Any?]) {
        updateState { state, realm in
            state.currentUser = realm.create(UserObject.self, value: value, update: true)
            state.session?.currentUser = state.currentUser
        }
    }
    
    func onLogout() {
        updateState { state, realm in
            state.currentUser = nil
            state.session?.currentUser = state.currentUser
        }
    }
    
    func onViewMedium(mediumId: String) {
        updateState { state, realm in
            state.previousMediumId = state.currentMediumId
            state.currentMediumId = mediumId
            state.triggerRecommendMedium = true
        }
    }
    
    func onRecommendMediumCompleted() {
        updateState { state, realm in
            state.triggerRecommendMedium = false
        }
    }
    
    private func updateState(_ mutation: @escaping (AppStateObject, Realm) -> ()) {
        DispatchQueue.realm.async {
            let realm = try! Realm()
            guard let _state = realm.object(ofType: AppStateObject.self, forPrimaryKey: AppStateObject.appPrimaryKey) else { return }
            try? realm.write {
                mutation(_state, realm)
                realm.add(_state, update: true)
            }
        }
    }
}

let appStore = AppStore()

