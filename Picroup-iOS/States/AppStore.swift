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

class UserObject: Object {
    @objc dynamic var _id: String?
    @objc dynamic var username: String?
    @objc dynamic var avatarId: String?
    let followingsCount = RealmOptional<Int>()
    let followersCount = RealmOptional<Int>()
    let reputation = RealmOptional<Int>()
    let gainedReputation = RealmOptional<Int>()
    let notificationsCount = RealmOptional<Int>()

    override static func primaryKey() -> String {
        return "_id"
    }
}

class AppStateObject: Object {
    @objc dynamic var _id: String?
    @objc dynamic var currentUser: UserObject?
    
    override static func primaryKey() -> String {
        return "_id"
    }
}

extension AppStateObject {
    private static let appPrimaryKey = "current"
    static let shared: AppStateObject = {
        let realm = try! Realm()
        if let result = realm.object(ofType: AppStateObject.self, forPrimaryKey: AppStateObject.appPrimaryKey) {
            return result
        }
        let result = AppStateObject()
        result._id = AppStateObject.appPrimaryKey
        try! realm.write {
            realm.add(result, update: true)
        }
        return result
    }()
}

class Store {
    
    lazy var state = Observable.from(object: _state).asDriver(onErrorDriveWith: .empty())
    lazy var _state: AppStateObject = AppStateObject.shared
    
    func onLogin(_ value: [String: Any?]) {
        updateState { state, realm in
            state.currentUser = realm.create(UserObject.self, value: value, update: true)
        }
    }
    
    func onLogout() {
        updateState { state, realm in
            state.currentUser = nil
        }
    }
    
    private func updateState(_ mutation: (AppStateObject, Realm) -> ()) {
        let realm = try! Realm()
        try! realm.write {
            mutation(_state, realm)
            realm.add(_state, update: true)
        }
    }
}

let store = Store()

