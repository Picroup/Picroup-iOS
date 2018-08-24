//
//  UpdateUserStateObject+Event.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/23.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift
import RxCocoa
import RxRealm
import RxAlamofire

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
            popRoute?.updateVersion()
        }
    }
}
