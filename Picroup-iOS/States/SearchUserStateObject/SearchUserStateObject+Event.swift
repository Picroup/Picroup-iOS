//
//  SearchUserStateObject+Event.swift
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

extension SearchUserStateObject {
    
    enum Event {
        case onChangeSearchText(String)
        case onSearchUserSuccess(SearchUserQuery.Data.SearchUser?)
        case onSearchUserError(Error)
        
        case onTriggerFollowUser(String)
        case onFollowUserSuccess(FollowUserMutation.Data.FollowUser)
        case onFollowUserError(Error)
        
        case onTriggerUnfollowUser(String)
        case onUnfollowUserSuccess(UnfollowUserMutation.Data.UnfollowUser)
        case onUnfollowUserError(Error)
        
        case onTriggerShowUser(String)
    }
}

extension SearchUserStateObject: IsFeedbackStateObject {
    
    func reduce(event: Event, realm: Realm) {
        switch event {
        case .onChangeSearchText(let searchText):
            searchUserQueryState?.reduce(event: .onChangeSearchText(searchText), realm: realm)
        case .onSearchUserSuccess(let data):
            searchUserQueryState?.reduce(event: .onSuccess(data), realm: realm)
        case .onSearchUserError(let error):
            searchUserQueryState?.reduce(event: .onError(error), realm: realm)
            
        case .onTriggerFollowUser(let toUserId):
            followUserQueryState?.reduce(event: .onTriggerFollowUser(toUserId), realm: realm)
        case .onFollowUserSuccess(let data):
            followUserQueryState?.reduce(event: .onSuccess(data), realm: realm)
            needUpdate?.myInterestedMedia = true
        case .onFollowUserError(let error):
            followUserQueryState?.reduce(event: .onError(error), realm: realm)
            
        case .onTriggerUnfollowUser(let toUserId):
            unfollowUserQueryState?.reduce(event: .onTriggerUnfollowUser(toUserId), realm: realm)
        case .onUnfollowUserSuccess(let data):
            unfollowUserQueryState?.reduce(event: .onSuccess(data), realm: realm)
            needUpdate?.myInterestedMedia = true
        case .onUnfollowUserError(let error):
            unfollowUserQueryState?.reduce(event: .onError(error), realm: realm)
            
        case .onTriggerShowUser(let userId):
            routeState?.reduce(event: .onTriggerShowUser(userId), realm: realm)
        }
    }
}
