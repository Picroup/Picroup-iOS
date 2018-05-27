//
//  Realm+background.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/14.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift

extension Realm {
    
    static func background(updates: @escaping (Realm) throws -> Void, onError: @escaping (Swift.Error) -> Void) {
        DispatchQueue.realm.async {
            do {
                let realm = try Realm()
                try updates(realm)
            } catch {
                onError(error)
            }
        }
    }
    
    static func backgroundReduce<StateObject, KeyType>(ofType type: StateObject.Type, forPrimaryKey key: KeyType, event: StateObject.Event)
        where StateObject: Object, StateObject: IsFeedbackStateObject {
        background(updates: { realm in
            guard let state = realm.object(ofType: type, forPrimaryKey: key) else {
                print("error: \(type) is lost")
                return
            }
            try realm.write {
                state.reduce(event: event, realm: realm)
            }
        }, onError: { error in
            print("realm error:", error)
        })
    }
}
