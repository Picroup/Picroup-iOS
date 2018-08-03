//
//  UpdateUserStateObject.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/6/4.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift
import RxCocoa
import RxRealm
import RxAlamofire

final class UpdateUserStateObject: PrimaryObject {
    
    typealias SetImageKeyQuery = (userId: String, imageKey: String)
    
    @objc dynamic var session: UserSessionObject?
    
    @objc dynamic var imageKey: String?
    @objc dynamic var setAvatarIdError: String?
    @objc dynamic var triggerSetAvatarIdQuery: Bool = false
    
    @objc dynamic var displayName: String = ""
    @objc dynamic var setDisplayNameError: String?
    @objc dynamic var triggerSetDisplayNameQuery: Bool = false

    @objc dynamic var popRoute: PopRouteObject?
}

extension UpdateUserStateObject {
    var setImageKeyQuery: SetImageKeyQuery? {
        guard let userId = session?.currentUserId,
            let imageKey = imageKey
            else { return nil }
        let next = (userId, imageKey)
        return triggerSetAvatarIdQuery ? next : nil
    }
    var setDisplayNameQuery: UserSetDisplayNameQuery? {
        guard let userId = session?.currentUserId else { return nil }
        let next = UserSetDisplayNameQuery(userId: userId, displayName: displayName)
        return triggerSetDisplayNameQuery ? next : nil
    }
    var shouldSetDisplay: Bool {
        return displayName.matchExpression(RegularPattern.displayName)
    }
}

extension UpdateUserStateObject {
    
    static func create() -> (Realm) throws -> UpdateUserStateObject {
        return { realm in
            let _id = PrimaryKey.default
            let value: Any = [
                "_id": _id,
                "session": ["_id": _id],
                "popRoute": ["_id": _id],
                ]
            let result = try realm.update(UpdateUserStateObject.self, value: value)
            try realm.write {
                result.imageKey = nil
                result.displayName = result.session?.currentUser?.displayName ?? ""
            }
            return result
        }
    }
}

extension UpdateUserStateObject {
    
    enum Event {
        case onChangeImageKey(String)
        case onSetAvatarIdSuccess(UserFragment)
        case onSetAvatarIdError(Error)
        
        case onTriggerSetDisplayName(String)
        case onSetDisplayNameSuccess(UserFragment)
        case onSetDisplayNameError(Error)
        case onTriggerPop
    }
}

extension UpdateUserStateObject: IsFeedbackStateObject {
    
    func reduce(event: UpdateUserStateObject.Event, realm: Realm) {
        switch event {
        case .onChangeImageKey(let imageKey):
            self.imageKey = imageKey
            setAvatarIdError = nil
            triggerSetAvatarIdQuery = true
        case .onSetAvatarIdSuccess(let data):
            session?.currentUser = UserObject.create(from: data)(realm)
            setAvatarIdError = nil
            triggerSetAvatarIdQuery = false
        case .onSetAvatarIdError(let error):
            setAvatarIdError = error.localizedDescription
            triggerSetAvatarIdQuery = false
            
        case .onTriggerSetDisplayName(let displayName):
            self.displayName = displayName
            guard shouldSetDisplay else { return }
            setDisplayNameError = nil
            triggerSetDisplayNameQuery = true
        case .onSetDisplayNameSuccess(let data):
            session?.currentUser = UserObject.create(from: data)(realm)
            setDisplayNameError = nil
            triggerSetDisplayNameQuery = false
        case .onSetDisplayNameError(let error):
            self.displayName = session?.currentUser?.displayName ?? ""
            setDisplayNameError = error.localizedDescription
            triggerSetDisplayNameQuery = false
            
        case .onTriggerPop:
            popRoute?.version = UUID().uuidString
        }
    }
}

final class UpdateUserStateStore {
    
    let states: Driver<UpdateUserStateObject>
    private let _state: UpdateUserStateObject
    
    init() throws {
        
        let realm = try Realm()
        let _state = try UpdateUserStateObject.create()(realm)
        let states = Observable.from(object: _state).asDriver(onErrorDriveWith: .empty())
        
        self._state = _state
        self.states = states
    }
    
    func on(event: UpdateUserStateObject.Event) {
        let id = PrimaryKey.default
        Realm.backgroundReduce(ofType: UpdateUserStateObject.self, forPrimaryKey: id, event: event)
    }
}
