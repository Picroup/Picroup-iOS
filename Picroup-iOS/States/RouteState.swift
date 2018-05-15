//
//  RouteState.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/15.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift
import RxSwift
import RxCocoa
import RxRealm

final class RouteStateObject: PrimaryObject {
    
    @objc dynamic var session: UserSessionObject?
    @objc dynamic var imageDetialRoute: ImageDetialRoute?
    @objc dynamic var poplRoute: PopRoute?
}

final class ImageDetialRoute: PrimaryObject {
    
    @objc dynamic var mediumId: String?
    @objc dynamic var version: String?
}

final class PopRoute: PrimaryObject {
    @objc dynamic var version: String?
}

extension RouteStateObject {
    
    static func create() -> (Realm) throws -> RouteStateObject {
        return { realm in
            let _id = Config.realmDefaultPrimaryKey
            let value: Any = [
                "_id": _id,
                "session": ["_id": _id],
                "imageDetialRoute": ["_id": _id],
                "poplRoute": ["_id": _id],
                ]
            return try realm.findOrCreate(RouteStateObject.self, forPrimaryKey: _id, value: value)
        }
    }
}

final class RouteStateStore {
    
    let states: Driver<RouteStateObject>
    private let _state: RouteStateObject
    
    init() throws {
        let realm = try Realm()
        let _state = try RouteStateObject.create()(realm)
        let states = Observable.from(object: _state).asDriver(onErrorDriveWith: .empty())
        
        self._state = _state
        self.states = states
    }
    
    func imageDetialRoute() -> Driver<ImageDetialRoute> {
        guard let imageDetialRoute = _state.imageDetialRoute else { return .empty() }
        return Observable.from(object: imageDetialRoute).asDriver(onErrorDriveWith: .empty())
    }
    
    func poplRoute() -> Driver<PopRoute> {
        guard let poplRoute = _state.poplRoute else { return .empty() }
        return Observable.from(object: poplRoute).asDriver(onErrorDriveWith: .empty())
    }
}
