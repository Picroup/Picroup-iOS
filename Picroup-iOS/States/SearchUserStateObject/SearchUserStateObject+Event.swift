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
            self.searchText = searchText
            user = nil
            let shouldQuery = !searchText.isEmpty
            triggerSearchUserQuery = shouldQuery
        case .onSearchUserSuccess(let data):
            user = data.map { realm.create(UserObject.self, value: $0.snapshot, update: true) }
            searchError = nil
            triggerSearchUserQuery = false
        case .onSearchUserError(let error):
            searchError = error.localizedDescription
            triggerSearchUserQuery = false
            
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
            userRoute?.updateVersion()
        }
    }
}
