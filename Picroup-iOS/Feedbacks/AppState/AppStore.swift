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
        updateState {
            $0.currentUser = UserObject(value: value)
        }
    }
    
    func onLogout() {
        updateState {
            $0.currentUser = nil
        }
    }
    
    private func updateState(_ mutation: (AppStateObject) -> ()) {
        let realm = try! Realm()
        try! realm.write {
            mutation(_state)
            realm.add(_state, update: true)
        }
    }
}

let store = Store()

