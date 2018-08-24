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
        case onGetReloadUserFollowings(UserBlockingUsersQuery.Data.User)
        case onGetUserFollowingsError(Error)
        
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
            userBlockingsError = nil
            triggerUserBlockingsQuery = true
        case .onGetReloadUserFollowings(let data):
        {
            userBlockings.removeAll()
            let users: [UserObject] = data.blockingUsers.map {
                let user = realm.create(UserObject.self, value: $0.snapshot, update: true)
                user.blocked.value = true
                return user
            }
            userBlockings.append(objectsIn: users)
        }()
        userBlockingsError = nil
        triggerUserBlockingsQuery = false
        case .onGetUserFollowingsError(let error):
            userBlockingsError = error.localizedDescription
            triggerUserBlockingsQuery = false
            
        case .onTriggerBlockUser(let blockingUserId):
            guard shouldBlockUser else { return }
            self.blockingUserId = blockingUserId
            blockUserError = nil
            triggerBlockUserQuery = true
        case .onBlockUserSuccess(let data):
            let user = realm.create(UserObject.self, value: data.snapshot, update: true)
            user.blocked.value = true
            blockingUserId = nil
            blockUserError = nil
            triggerBlockUserQuery = false
            needUpdate?.myInterestedMedia = true
            needUpdate?.myStaredMedia = true
        case .onBlockUserError(let error):
            blockUserError = error.localizedDescription
            triggerBlockUserQuery = false
            
        case .onTriggerUnblockUser(let toUserId):
            guard shouldUnblockUser else { return }
            unblockingUserId = toUserId
            unblockUserError = nil
            triggerUnblockUserQuery = true
        case .onUnblockUserSuccess(let data):
            let user = realm.create(UserObject.self, value: data.snapshot, update: true)
            user.blocked.value = false
            unblockingUserId = nil
            unblockUserError = nil
            triggerUnblockUserQuery = false
            needUpdate?.myInterestedMedia = true
            needUpdate?.myStaredMedia = true
        case .onUnblockUserError(let error):
            unblockUserError = error.localizedDescription
            triggerUnblockUserQuery = false
            
        case .onTriggerShowUser(let userId):
            routeState?.reduce(event: .onTriggerShowUser(userId), realm: realm)
        }
    }
}
