//
//  UserStateObject+Event.swift
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

extension UserStateObject {
    
    enum Event {
        case onTriggerReloadUser
        case onGetUserSuccess(UserQuery.Data.User)
        case onGetUserError(Error)
        
        case userMediaState(CursorMediaStateObject.Event)
        
        case onTriggerFollowUser
        case onFollowUserSuccess(FollowUserMutation.Data.FollowUser)
        case onFollowUserError(Error)
        
        case onTriggerUnfollowUser
        case onUnfollowUserSuccess(UnfollowUserMutation.Data.UnfollowUser)
        case onUnfollowUserError(Error)
        
        case onTriggerBlockUser
        case onBlockUserSuccess(UserFragment)
        case onBlockUserError(Error)
        
        case onTriggerLogin
        case onTriggerShowImage(String)
        case onTriggerShowUserFollowings
        case onTriggerShowUserFollowers
        case onTriggerUserFeedback
        case onTriggerPop
    }
}

extension UserStateObject: IsFeedbackStateObject {
    
    func reduce(event: Event, realm: Realm) {
        switch event {
        case .onTriggerReloadUser:
            userError = nil
            triggerUserQuery = true
        case .onGetUserSuccess(let data):
            user = realm.create(UserObject.self, value: data.snapshot, update: true)
            userError = nil
            triggerUserQuery = false
        case .onGetUserError(let error):
            userError = error.localizedDescription
            triggerUserQuery = false
            
        case .userMediaState(let event):
            userMediaState?.reduce(event: event, realm: realm)
            
        case .onTriggerFollowUser:
            guard shouldFollowUser else { return }
            followUserVersion = nil
            followUserError = nil
            triggerFollowUserQuery = true
        case .onFollowUserSuccess(let data):
            user = realm.create(UserObject.self, value: data.snapshot, update: true)
            followUserVersion = UUID().uuidString
            followUserError = nil
            triggerFollowUserQuery = false
            needUpdate?.myInterestedMedia = true
            
            snackbar?.message = "已关注 @\(user?.username ?? "")"
            snackbar?.version = UUID().uuidString
        case .onFollowUserError(let error):
            followUserVersion = nil
            followUserError = error.localizedDescription
            triggerFollowUserQuery = false
            
        case .onTriggerUnfollowUser:
            guard shouldUnfollowUser else { return }
            unfollowUserVersion = nil
            unfollowUserError = nil
            triggerUnfollowUserQuery = true
        case .onUnfollowUserSuccess(let data):
            user = realm.create(UserObject.self, value: data.snapshot, update: true)
            unfollowUserVersion = UUID().uuidString
            unfollowUserError = nil
            triggerUnfollowUserQuery = false
            needUpdate?.myInterestedMedia = true
            snackbar?.message = "已取消关注 @\(user?.username ?? "")"
            snackbar?.version = UUID().uuidString
        case .onUnfollowUserError(let error):
            unfollowUserVersion = nil
            unfollowUserError = error.localizedDescription
            triggerUnfollowUserQuery = false
            
        case .onTriggerBlockUser:
            guard shouldBlockUser else { return }
            blockUserVersion = nil
            blockUserError = nil
            triggerBlockUserQuery = true
        case .onBlockUserSuccess(let data):
            let blockedMedia = realm.objects(MediumObject.self).filter("userId = %@", data.id)
            realm.delete(blockedMedia)
            blockUserVersion = UUID().uuidString
            blockUserError = nil
            triggerBlockUserQuery = false
            needUpdate?.myInterestedMedia = true
            snackbar?.message = "已拉黑 @\(user?.username ?? "")，您可以前往设置取消拉黑"
            snackbar?.version = UUID().uuidString
        case .onBlockUserError(let error):
            blockUserVersion = nil
            blockUserError = error.localizedDescription
            triggerBlockUserQuery = false
            
        case .onTriggerLogin:
            loginRoute?.version = UUID().uuidString
        case .onTriggerShowImage(let mediumId):
            imageDetialRoute?.mediumId = mediumId
            imageDetialRoute?.version = UUID().uuidString
        case .onTriggerShowUserFollowings:
            userFollowingsRoute?.userId = user?._id
            userFollowingsRoute?.version = UUID().uuidString
        case .onTriggerShowUserFollowers:
            userFollowersRoute?.userId = user?._id
            userFollowersRoute?.version = UUID().uuidString
        case .onTriggerUserFeedback:
            feedbackRoute?.triggerUser(toUserId: userId)
        case .onTriggerPop:
            popRoute?.version = UUID().uuidString
        }
        version = UUID().uuidString
    }
}
