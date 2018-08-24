//
//  MainStateObject.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/24.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift
import RxCocoa
import RxRealm

final class MainStateObject: PrimaryObject {
    
    @objc dynamic var sessionStateState: UserSessionStateObject?
    
}

extension MainStateObject {
    
    static func create() -> (Realm) throws -> MainStateObject {
        return { realm in
            let _id = PrimaryKey.default
            let value: Any = [
                "_id": _id,
                "sessionStateState": ["_id": _id],
                ]
            return try realm.update(MainStateObject.self, value: value)
        }
    }
}

