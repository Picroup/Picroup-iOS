//
//  RegisterUsernameStateObject.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/6/6.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift
import RxSwift
import RxCocoa

final class RegisterParamObject: PrimaryObject {
    
    @objc dynamic var username: String = ""
    @objc dynamic var password: String = ""
    @objc dynamic var phoneNumber: String = ""
    @objc dynamic var code: Double = 0
}

final class RegisterUsernameStateObject: PrimaryObject {
    
    @objc dynamic var registerParam: RegisterParamObject?
    @objc dynamic var isUsernameAvaliable: Bool = false
    @objc dynamic var triggerValidUsernameQuery: Bool = false
}

extension RegisterUsernameStateObject {
    var usernameAvailableQuery: UserAvailableQuery? {
        guard let username = registerParam?.username, !username.isEmpty else {
            return nil
        }
        let next = UserAvailableQuery(username: username)
        return triggerValidUsernameQuery ? next : nil
    }
    var shouldValidUsername: Bool {
        return registerParam?.username.count ?? 0 >= minimalUsernameLength
    }
}

extension RegisterUsernameStateObject {
    
    static func create() -> (Realm) throws -> RegisterUsernameStateObject {
        return { realm in
            let _id = PrimaryKey.default
            let value: Any = [
                "_id": _id,
                "registerParam": ["_id": _id],
                "isUsernameAvaliable": false,
                ]
            return try realm.update(RegisterUsernameStateObject.self, value: value)
        }
    }
}

extension RegisterUsernameStateObject {
    
    enum Event {
        case onChangeUsername(String)
        case onUserAvailableResponse(String?)
    }
}

extension RegisterUsernameStateObject: IsFeedbackStateObject {
    
    func reduce(event: RegisterUsernameStateObject.Event, realm: Realm) {
        switch event {
        case .onChangeUsername(let username):
            self.registerParam?.username = username
            self.isUsernameAvaliable = false
            guard shouldValidUsername else { return }
            self.triggerValidUsernameQuery = true
        case .onUserAvailableResponse(let data):
            self.isUsernameAvaliable = data == nil
            self.triggerValidUsernameQuery = false
        }
    }
}

final class RegisterUsernameStateStore {
    
    let states: Driver<RegisterUsernameStateObject>
    private let _state: RegisterUsernameStateObject
    
    init() throws {
        
        let realm = try Realm()
        let _state = try RegisterUsernameStateObject.create()(realm)
        let states = Observable.from(object: _state).asDriver(onErrorDriveWith: .empty())
        
        self._state = _state
        self.states = states
    }
    
    func on(event: RegisterUsernameStateObject.Event) {
        let id = PrimaryKey.default
        Realm.backgroundReduce(ofType: RegisterUsernameStateObject.self, forPrimaryKey: id, event: event)
    }
}

extension UserAvailableQuery: Equatable {
    public static func ==(lhs: UserAvailableQuery, rhs: UserAvailableQuery) -> Bool {
        return lhs.username == rhs.username
    }
}
