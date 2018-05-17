//
//  HomeStateObject.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/17.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift
import RxSwift
import RxCocoa

final class HomeStateObject: PrimaryObject {
    
    @objc dynamic var session: UserSessionObject?

    @objc dynamic var isFABMenuOpened: Bool = false
    @objc dynamic var triggerFABMenuCloseVersion: String?
    
    @objc dynamic var pickImageRoute: PickImageRouteObject?
}

extension HomeStateObject {
    
    static func create() -> (Realm) throws -> HomeStateObject {
        return { realm in
            let _id = Config.realmDefaultPrimaryKey
            let value: Any = [
                "_id": _id,
                "session": ["_id": _id],
                "pickImageRoute": ["_id": _id],
                ]
            let state = try realm.findOrCreate(HomeStateObject.self, forPrimaryKey: _id, value: value)
            try realm.write {
                state.isFABMenuOpened = false
            }
            return state
        }
    }
}

extension HomeStateObject {
    
    enum Event {
        case fabMenuWillOpen
        case fabMenuWillClose
        case triggerFABMenuClose
        case triggerPickImage(UIImagePickerControllerSourceType)
    }
}

extension HomeStateObject: IsFeedbackStateObject {
    
    func reduce(event: Event, realm: Realm) {
        switch event {
        case .fabMenuWillOpen:
            isFABMenuOpened = true
            triggerFABMenuCloseVersion = nil
        case .fabMenuWillClose:
            isFABMenuOpened = false
            triggerFABMenuCloseVersion = nil
        case .triggerFABMenuClose:
            isFABMenuOpened = false
            triggerFABMenuCloseVersion = UUID().uuidString
        case .triggerPickImage(let sourceType):
            pickImageRoute?.sourceType.value = sourceType.rawValue
            pickImageRoute?.version = UUID().uuidString
        }
    }
}

final class HomeStateStore {
    
    let states: Driver<HomeStateObject>
    private let _state: HomeStateObject
    
    init() throws {
        let realm = try Realm()
        let _state = try HomeStateObject.create()(realm)
        let states = Observable.from(object: _state).asDriver(onErrorDriveWith: .empty())
        
        self._state = _state
        self.states = states
    }
    
    func on(event: HomeStateObject.Event) {
        let id = Config.realmDefaultPrimaryKey
        Realm.backgroundReduce(ofType: HomeStateObject.self, forPrimaryKey: id, event: event)
    }
}
