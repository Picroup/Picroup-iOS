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
    @objc dynamic var imageDetialRoute: ImageDetialRouteObject?
    @objc dynamic var imageCommetsRoute: ImageCommetsRouteObject?
    @objc dynamic var reputationsRoute: ReputationsRouteObject?
    @objc dynamic var pickImageRoute: PickImageRouteObject?
    @objc dynamic var createImageRoute: CreateImageRouteObject?
    @objc dynamic var userRoute: UserRouteObject?
    @objc dynamic var userFollowingsRoute: UserFollowingsRouteObject?
    @objc dynamic var popRoute: PopRouteObject?
}

final class ImageDetialRouteObject: PrimaryObject {
    
    @objc dynamic var mediumId: String?
    @objc dynamic var version: String?
}

final class ImageCommetsRouteObject: PrimaryObject {
    
    @objc dynamic var mediumId: String?
    @objc dynamic var version: String?
}

final class ReputationsRouteObject: PrimaryObject {
    @objc dynamic var version: String?
}

final class PickImageRouteObject: PrimaryObject {
    let sourceType = RealmOptional<Int>()
    @objc dynamic var version: String?
}

final class CreateImageRouteObject: PrimaryObject {
    @objc dynamic var imageKey: String?
    @objc dynamic var version: String?
}

final class UserRouteObject: PrimaryObject {
    
    @objc dynamic var userId: String?
    @objc dynamic var version: String?
}

final class UserFollowingsRouteObject: PrimaryObject {
    
    @objc dynamic var userId: String?
    @objc dynamic var version: String?
}

final class PopRouteObject: PrimaryObject {
    @objc dynamic var version: String?
}

extension RouteStateObject {
    
    static func create() -> (Realm) throws -> RouteStateObject {
        return { realm in
            let _id = PrimaryKey.default
            let value: Any = [
                "_id": _id,
                "session": ["_id": _id],
                "imageDetialRoute": ["_id": _id],
                "imageCommetsRoute": ["_id": _id],
                "reputationsRoute": ["_id": _id],
                "pickImageRoute": ["_id": _id],
                "createImageRoute": ["_id": _id],
                "userRoute": ["_id": _id],
                "userFollowingsRoute": ["_id": _id],
                "popRoute": ["_id": _id],
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
    
    func session() -> Driver<UserSessionObject> {
        guard let session = _state.session else { return .empty() }
        return Observable.from(object: session).asDriver(onErrorDriveWith: .empty())
    }
    
    func imageDetialRoute() -> Driver<ImageDetialRouteObject> {
        guard let imageDetialRoute = _state.imageDetialRoute else { return .empty() }
        return Observable.from(object: imageDetialRoute).asDriver(onErrorDriveWith: .empty())
    }
    
    func imageCommetsRoute() -> Driver<ImageCommetsRouteObject> {
        guard let imageDetialRoute = _state.imageCommetsRoute else { return .empty() }
        return Observable.from(object: imageDetialRoute).asDriver(onErrorDriveWith: .empty())
    }
    
    func reputationsRoute() -> Driver<ReputationsRouteObject> {
        guard let popRoute = _state.reputationsRoute else { return .empty() }
        return Observable.from(object: popRoute).asDriver(onErrorDriveWith: .empty())
    }
    
    func pickImageRoute() -> Driver<PickImageRouteObject> {
        guard let popRoute = _state.pickImageRoute else { return .empty() }
        return Observable.from(object: popRoute).asDriver(onErrorDriveWith: .empty())
    }
    
    func createImageRoute() -> Driver<CreateImageRouteObject> {
        guard let popRoute = _state.createImageRoute else { return .empty() }
        return Observable.from(object: popRoute).asDriver(onErrorDriveWith: .empty())
    }
    
    func userRoute() -> Driver<(UserRouteObject, Bool)> {
        guard let userRoute = _state.userRoute else { return .empty() }
        return Observable.from(object: userRoute)
            .map { ($0, self._state.session?.currentUser?._id == $0.userId) }
            .asDriver(onErrorDriveWith: .empty())
    }
    
    func userFollowingsRoute() -> Driver<UserFollowingsRouteObject> {
        guard let userFollowingsRoute = _state.userFollowingsRoute else { return .empty() }
        return Observable.from(object: userFollowingsRoute).asDriver(onErrorDriveWith: .empty())
    }
    
    func popRoute() -> Driver<PopRouteObject> {
        guard let popRoute = _state.popRoute else { return .empty() }
        return Observable.from(object: popRoute).asDriver(onErrorDriveWith: .empty())
    }
}
