//
//  UpdatePasswordStateObject.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/6/7.
//  Copyright © 2018年 luojie. All rights reserved.
//


import RealmSwift
import RxSwift
import RxCocoa

final class UpdatePasswordStateObject: PrimaryObject {
    
    @objc dynamic var session: UserSessionObject?
    
    @objc dynamic var oldPassword: String = ""
    @objc dynamic var password: String = ""
    
    @objc dynamic var isOldPasswordValid: Bool = false
    @objc dynamic var isPasswordValid: Bool = false
    
    @objc dynamic var setPasswordError: String?
    @objc dynamic var triggerSetPasswordQuery: Bool = false
    
    @objc dynamic var popRoute: PopRouteObject?
    @objc dynamic var snackbar: SnackbarObject?
}

extension UpdatePasswordStateObject {
    var setPasswordQuery: UserSetPasswordQuery? {
        guard let userId = session?.currentUserId else { return nil }
        let next = UserSetPasswordQuery(userId: userId, password: password, oldPassword: oldPassword)
        return triggerSetPasswordQuery ? next : nil
    }
    var shouldSetPassword: Bool {
        return isOldPasswordValid && isPasswordValid && !triggerSetPasswordQuery
    }
}

extension UpdatePasswordStateObject {
    
    static func create() -> (Realm) throws -> UpdatePasswordStateObject {
        return { realm in
            let _id = PrimaryKey.default
            let value: Any = [
                "_id": _id,
                "session": ["_id": _id],
                "oldPassword": "",
                "password": "",
                "isOldPasswordValid": false,
                "isPasswordValid": false,
                "popRoute": ["_id": _id],
                "snackbar": ["_id": _id],
                ]
            return try realm.update(UpdatePasswordStateObject.self, value: value)
        }
    }
}

extension UpdatePasswordStateObject {
    
    enum Event {
        case onChangeOldPassword(String)
        case onChangePassword(String)
        
        case onTriggerSetPassword
        case onSetPasswordSuccess(UserFragment)
        case onSetPasswordError(Error)
        
        case onTriggerPop
    }
}

extension UpdatePasswordStateObject: IsFeedbackStateObject {
    
    func reduce(event: UpdatePasswordStateObject.Event, realm: Realm) {
        switch event {
        case .onChangeOldPassword(let password):
            self.oldPassword = password
            self.isOldPasswordValid = password.matchExpression(RegularPattern.password)
        case .onChangePassword(let password):
            self.password = password
            self.isPasswordValid = password.matchExpression(RegularPattern.password)
            
        case .onTriggerSetPassword:
            guard shouldSetPassword else { return }
            setPasswordError = nil
            triggerSetPasswordQuery = true
        case .onSetPasswordSuccess(let data):
            session?.currentUser = UserObject.create(from: data)(realm)
            setPasswordError = nil
            triggerSetPasswordQuery = false
            
            snackbar?.message = "密码已修改"
            snackbar?.version = UUID().uuidString
            
            popRoute?.version = UUID().uuidString
        case .onSetPasswordError(let error):
            setPasswordError = error.localizedDescription
            triggerSetPasswordQuery = false
            
            snackbar?.message = setPasswordError
            snackbar?.version = UUID().uuidString
        case .onTriggerPop:
            popRoute?.version = UUID().uuidString
        }
    }
}

final class UpdatePasswordStateStore {
    
    let states: Driver<UpdatePasswordStateObject>
    private let _state: UpdatePasswordStateObject
    
    init() throws {
        
        let realm = try Realm()
        let _state = try UpdatePasswordStateObject.create()(realm)
        let states = Observable.from(object: _state).asDriver(onErrorDriveWith: .empty())
        
        self._state = _state
        self.states = states
    }
    
    func on(event: UpdatePasswordStateObject.Event) {
        let id = PrimaryKey.default
        Realm.backgroundReduce(ofType: UpdatePasswordStateObject.self, forPrimaryKey: id, event: event)
    }
}


