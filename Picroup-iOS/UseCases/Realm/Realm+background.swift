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
}
