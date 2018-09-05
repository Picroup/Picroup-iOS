//
//  UserBlockingsStateObject+Event.swift
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

extension UserBlockingsStateObject {
    
    enum Event {
        case onTriggerReloadUserBlockings
        case onGetUserBlockingsData([UserFragment])
        case onGetUserBlockingsError(Error)
        
        case onTriggerBlockUser(String)
        case onBlockUserSuccess(BlockUserMutation.Data.BlockUser)
        case onBlockUserError(Error)
        
        case onTriggerUnblockUser(String)
        case onUnblockUserSuccess(UnblockUserMutation.Data.UnblockUser)
        case onUnblockUserError(Error)
        
        case onTriggerShowUser(String)
    }
}

extension UserBlockingsStateObject: IsFeedbackStateObject {
    
    func reduce(event: Event, realm: Realm) {
        switch event {
        case .onTriggerReloadUserBlockings:
            userBlockingUsersQueryState?.reduce(event: .onTrigger, realm: realm)
        case .onGetUserBlockingsData(let data):
            userBlockingUsersQueryState?.reduce(event: .onGetData(data), realm: realm)
        case .onGetUserBlockingsError(let error):
            userBlockingUsersQueryState?.reduce(event: .onGetError(error), realm: realm)
            
        case .onTriggerBlockUser(let blockingUserId):
            blockUserQueryState?.reduce(event: .onTriggerBlockUser(blockingUserId), realm: realm)
        case .onBlockUserSuccess(let data):
            blockUserQueryState?.reduce(event: .onSuccess(data), realm: realm)
            needUpdate?.myInterestedMedia = true
            needUpdate?.myStaredMedia = true
        case .onBlockUserError(let error):
            blockUserQueryState?.reduce(event: .onError(error), realm: realm)
            
        case .onTriggerUnblockUser(let toUserId):
            unblockUserQueryState?.reduce(event: .onTriggerUnblockUser(toUserId), realm: realm)
        case .onUnblockUserSuccess(let data):
            unblockUserQueryState?.reduce(event: .onSuccess(data), realm: realm)
            needUpdate?.myInterestedMedia = true
            needUpdate?.myStaredMedia = true
        case .onUnblockUserError(let error):
            unblockUserQueryState?.reduce(event: .onError(error), realm: realm)

        case .onTriggerShowUser(let userId):
            routeState?.reduce(event: .onTriggerShowUser(userId), realm: realm)
        }
    }
}
