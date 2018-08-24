//
//  UserFollowersStateObject+Event.swift
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

extension UserFollowersStateObject {
    
    enum Event {
        case onTriggerReloadUserFollowers
        case onTriggerGetMoreUserFollowers
        case onGetReloadUserFollowers(UserFollowersQuery.Data.User.Follower)
        case onGetMoreUserFollowers(UserFollowersQuery.Data.User.Follower)
        case onGetUserFollowersError(Error)
        
        case onTriggerFollowUser(String)
        case onFollowUserSuccess(FollowUserMutation.Data.FollowUser)
        case onFollowUserError(Error)
        
        case onTriggerUnfollowUser(String)
        case onUnfollowUserSuccess(UnfollowUserMutation.Data.UnfollowUser)
        case onUnfollowUserError(Error)
        
        case onTriggerShowUser(String)
        case onTriggerPop
    }
}

extension UserFollowersStateObject.Event {
    
    static func onGetUserFollowers(isReload: Bool) -> (UserFollowersQuery.Data.User.Follower) -> UserFollowersStateObject.Event {
        return { isReload ? .onGetReloadUserFollowers($0) : .onGetMoreUserFollowers($0) }
    }
}

extension UserFollowersStateObject: IsFeedbackStateObject {
    
    func reduce(event: Event, realm: Realm) {
        switch event {
        case .onTriggerReloadUserFollowers:
            userFollowers?.cursor.value = nil
            userFollowersError = nil
            triggerUserFollowersQuery = true
        case .onTriggerGetMoreUserFollowers:
            guard shouldQueryMoreUserFollowers else { return }
            userFollowersError = nil
            triggerUserFollowersQuery = true
        case .onGetReloadUserFollowers(let data):
            userFollowers = CursorUsersObject.create(from: data, id: PrimaryKey.userFollowersId(userId))(realm)
            userFollowersError = nil
            triggerUserFollowersQuery = false
        case .onGetMoreUserFollowers(let data):
            userFollowers?.merge(from: data)(realm)
            userFollowersError = nil
            triggerUserFollowersQuery = false
        case .onGetUserFollowersError(let error):
            userFollowersError = error.localizedDescription
            triggerUserFollowersQuery = false
            
        case .onTriggerFollowUser(let toUserId):
            guard shouldFollowUser else { return }
            followToUserId = toUserId
            followUserError = nil
            triggerFollowUserQuery = true
        case .onFollowUserSuccess(let data):
            realm.create(UserObject.self, value: data.snapshot, update: true)
            followToUserId = nil
            followUserError = nil
            triggerFollowUserQuery = false
            needUpdate?.myInterestedMedia = true
            
        case .onFollowUserError(let error):
            followUserError = error.localizedDescription
            triggerFollowUserQuery = false
            
        case .onTriggerUnfollowUser(let toUserId):
            guard shouldUnfollowUser else { return }
            unfollowToUserId = toUserId
            unfollowUserError = nil
            triggerUnfollowUserQuery = true
        case .onUnfollowUserSuccess(let data):
            realm.create(UserObject.self, value: data.snapshot, update: true)
            unfollowToUserId = nil
            unfollowUserError = nil
            triggerUnfollowUserQuery = false
            needUpdate?.myInterestedMedia = true
            
        case .onUnfollowUserError(let error):
            unfollowUserError = error.localizedDescription
            triggerUnfollowUserQuery = false
            
        case .onTriggerShowUser(let userId):
            routeState?.reduce(event: .onTriggerShowUser(userId), realm: realm)
        case .onTriggerPop:
            routeState?.reduce(event: .onTriggerPop, realm: realm)
        }
    }
}
