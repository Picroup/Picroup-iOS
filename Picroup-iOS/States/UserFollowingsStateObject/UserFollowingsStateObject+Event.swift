//
//  UserFollowingsStateObject+Event.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/23.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import Foundation
import RealmSwift
import RxSwift
import RxCocoa
import RxRealm

extension UserFollowingsStateObject {
    
    enum Event {
        case onTriggerReloadUserFollowings
        case onTriggerGetMoreUserFollowings
        case onGetReloadUserFollowings(UserFollowingsQuery.Data.User.Following)
        case onGetMoreUserFollowings(UserFollowingsQuery.Data.User.Following)
        case onGetUserFollowingsError(Error)
        
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

extension UserFollowingsStateObject.Event {
    
    static func onGetUserFollowings(isReload: Bool) -> (UserFollowingsQuery.Data.User.Following) -> UserFollowingsStateObject.Event {
        return { isReload ? .onGetReloadUserFollowings($0) : .onGetMoreUserFollowings($0) }
    }
}

extension UserFollowingsStateObject: IsFeedbackStateObject {
    
    func reduce(event: Event, realm: Realm) {
        switch event {
        case .onTriggerReloadUserFollowings:
            userFollowings?.cursor.value = nil
            userFollowingsError = nil
            triggerUserFollowingsQuery = true
        case .onTriggerGetMoreUserFollowings:
            guard shouldQueryMoreUserFollowings else { return }
            userFollowingsError = nil
            triggerUserFollowingsQuery = true
        case .onGetReloadUserFollowings(let data):
            userFollowings = CursorUsersObject.create(from: data, id: PrimaryKey.userFollowingsId(userId))(realm)
            userFollowingsError = nil
            triggerUserFollowingsQuery = false
        case .onGetMoreUserFollowings(let data):
            userFollowings?.merge(from: data)(realm)
            userFollowingsError = nil
            triggerUserFollowingsQuery = false
        case .onGetUserFollowingsError(let error):
            userFollowingsError = error.localizedDescription
            triggerUserFollowingsQuery = false
            
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
            userRoute?.userId = userId
            userRoute?.version = UUID().uuidString
        case .onTriggerPop:
            popRoute?.version = UUID().uuidString
        }
    }
}
