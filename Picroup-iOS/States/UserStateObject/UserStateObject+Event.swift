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
        
        case onTriggerReloadUserMedia
        case onTriggerGetMoreUserMedia
        case onGetUserMediaData(CursorMediaFragment)
        case onGetUserMediaError(Error)
        
        case onTriggerFollowUser
        case onFollowUserSuccess(FollowUserMutation.Data.FollowUser)
        case onFollowUserError(Error)
        
        case onTriggerUnfollowUser
        case onUnfollowUserSuccess(UnfollowUserMutation.Data.UnfollowUser)
        case onUnfollowUserError(Error)
        
        case onTriggerBlockUser
        case onBlockUserSuccess(BlockUserMutation.Data.BlockUser)
        case onBlockUserError(Error)
        
        case onTriggerStarMedium(String)
        case onStarMediumSuccess(StarMediumMutation.Data.StarMedium)
        case onStarMediumError(Error)
        
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
            userQueryState?.reduce(event: .onTrigger, realm: realm)
        case .onGetUserSuccess(let data):
            userQueryState?.reduce(event: .onSuccess(data), realm: realm)
        case .onGetUserError(let error):
            userQueryState?.reduce(event: .onError(error), realm: realm)
            
        case .onTriggerReloadUserMedia:
            userMediaQueryState?.reduce(event: .onTriggerReload, realm: realm)
        case .onTriggerGetMoreUserMedia:
            userMediaQueryState?.reduce(event: .onTriggerGetMore, realm: realm)
        case .onGetUserMediaData(let data):
            userMediaQueryState?.reduce(event: .onGetData(data), realm: realm)
        case .onGetUserMediaError(let error):
            userMediaQueryState?.reduce(event: .onGetError(error), realm: realm)
            
        case .onTriggerFollowUser:
            followUserQueryState?.reduce(event: .onTriggerFollowUser(userId), realm: realm)
        case .onFollowUserSuccess(let data):
            followUserQueryState?.reduce(event: .onSuccess(data), realm: realm)
            needUpdate?.myInterestedMedia = true
            snackbar?.reduce(event: .onUpdateMessage("已关注 @\(userQueryState?.user?.username ?? "")"), realm: realm)
        case .onFollowUserError(let error):
            followUserQueryState?.reduce(event: .onError(error), realm: realm)
            
        case .onTriggerUnfollowUser:
            unfollowUserQueryState?.reduce(event: .onTriggerUnfollowUser(userId), realm: realm)
        case .onUnfollowUserSuccess(let data):
            unfollowUserQueryState?.reduce(event: .onSuccess(data), realm: realm)
            needUpdate?.myInterestedMedia = true
            snackbar?.reduce(event: .onUpdateMessage("已取消关注 @\(userQueryState?.user?.username ?? "")"), realm: realm)
        case .onUnfollowUserError(let error):
            unfollowUserQueryState?.reduce(event: .onError(error), realm: realm)
            
        case .onTriggerBlockUser:
            blockUserQueryState?.reduce(event: .onTriggerBlockUser(userId), realm: realm)
        case .onBlockUserSuccess(let data):
            blockUserQueryState?.reduce(event: .onSuccess(data), realm: realm)
            needUpdate?.myInterestedMedia = true
            snackbar?.reduce(event: .onUpdateMessage("已拉黑 @\(userQueryState?.user?.username ?? "")，您可以前往设置取消拉黑"), realm: realm)
        case .onBlockUserError(let error):
            blockUserQueryState?.reduce(event: .onError(error), realm: realm)
            
        case .onTriggerStarMedium(let mediumId):
            guard sessionState?.isLogin == true else {
                routeState?.reduce(event: .onTriggerLogin, realm: realm)
                return
            }
            starMediumQueryState?.reduce(event: .onTrigger(mediumId), realm: realm)
        case .onStarMediumSuccess(let data):
            starMediumQueryState?.reduce(event: .onSuccess(data), realm: realm)
            needUpdate?.myStaredMedia = true
            snackbar?.reduce(event: .onUpdateMessage("感谢你给媒体续命一周"), realm: realm)
        case .onStarMediumError(let error):
            starMediumQueryState?.reduce(event: .onError(error), realm: realm)
            snackbar?.reduce(event: .onUpdateMessage(error.localizedDescription), realm: realm)
            
        case .onTriggerLogin:
            routeState?.reduce(event: .onTriggerLogin, realm: realm)
        case .onTriggerShowImage(let mediumId):
            routeState?.reduce(event: .onTriggerShowImage(mediumId), realm: realm)
        case .onTriggerShowUserFollowings:
            routeState?.reduce(event: .onTriggerShowUserFollowings(userId), realm: realm)
        case .onTriggerShowUserFollowers:
            routeState?.reduce(event: .onTriggerShowUserFollowers(userId), realm: realm)
        case .onTriggerUserFeedback:
            routeState?.reduce(event: .onTriggerUserFeedback(userId), realm: realm)
        case .onTriggerPop:
            routeState?.reduce(event: .onTriggerPop, realm: realm)
        }
    }
}
