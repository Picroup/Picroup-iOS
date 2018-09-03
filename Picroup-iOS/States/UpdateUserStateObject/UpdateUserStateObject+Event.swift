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
            setAvatarQueryState?.reduce(event: .onChangeImageKey(imageKey), realm: realm)
        case .onSetAvatarIdSuccess(let data):
            sessionState?.reduce(event: .onUpdateUser(data), realm: realm)
            setAvatarQueryState?.reduce(event: .onSuccess(data), realm: realm)
        case .onSetAvatarIdError(let error):
            setAvatarQueryState?.reduce(event: .onError(error), realm: realm)
            
        case .onTriggerSetDisplayName(let displayName):
            setDisplayNameQueryState?.reduce(event: .onTriggerSetDisplayName(displayName), realm: realm)
        case .onSetDisplayNameSuccess(let data):
            sessionState?.reduce(event: .onUpdateUser(data), realm: realm)
            setDisplayNameQueryState?.reduce(event: .onSuccess(data), realm: realm)
        case .onSetDisplayNameError(let error):
            setDisplayNameQueryState?.reduce(event: .onError(error), realm: realm)
            
        case .onTriggerPop:
            routeState?.reduce(event: .onTriggerPop, realm: realm)
        }
    }
}
