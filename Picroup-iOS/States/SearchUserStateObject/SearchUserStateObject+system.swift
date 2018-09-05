//
//  SearchUserStateStore.swift
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
import RxFeedback

extension SearchUserStateObject {
    
    func system(
        uiFeedback: @escaping DriverFeedback,
        shouldQuery: @escaping () -> Bool,
        searchUser: @escaping (SearchUserQuery) -> Single<SearchUserQuery.Data.SearchUser?>,
        followUser: @escaping (FollowUserMutation) -> Single<FollowUserMutation.Data.FollowUser>,
        unfollowUser: @escaping (UnfollowUserMutation) -> Single<UnfollowUserMutation.Data.UnfollowUser>
        ) -> Driver<SearchUserStateObject> {
        
        let searchUserFeedback: DriverFeedback = react(query: { $0.searchUserQuery }, effects: composeEffects(shouldQuery: shouldQuery) { query in
            return searchUser(query)
                .map(Event.onSearchUserSuccess)
                .asSignal(onErrorReturnJust: Event.onSearchUserError)
        })
        
        let followUserFeedback: DriverFeedback = react(query: { $0.followUserQuery }, effects: composeEffects(shouldQuery: shouldQuery) { query in
            return followUser(query)
                .map(Event.onFollowUserSuccess)
                .asSignal(onErrorReturnJust: Event.onFollowUserError)
        })
        
        let unfollowUserFeedback: DriverFeedback = react(query: { $0.unfollowUserQuery }, effects: composeEffects(shouldQuery: shouldQuery) { query in
            return unfollowUser(query)
                .map(Event.onUnfollowUserSuccess)
                .asSignal(onErrorReturnJust: Event.onUnfollowUserError)
        })
        
        return system(
            feedbacks: [uiFeedback, searchUserFeedback, followUserFeedback, unfollowUserFeedback],
            //            composeStates: { $0.debug("SearchUserState", trimOutput: false) },
            composeEvents: { $0.debug("SearchUserState.Event", trimOutput: true) }
        )
    }
}
