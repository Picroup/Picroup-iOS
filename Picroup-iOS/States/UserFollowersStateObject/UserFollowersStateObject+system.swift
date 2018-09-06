//
//  UserFollowersStateStore.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/23.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxFeedback

extension UserFollowersStateObject {
    
    func system(
        uiFeedback: @escaping DriverFeedback,
        shouldQuery: @escaping () -> Bool,
        queryUserFollowers: @escaping (UserFollowersQuery) -> Single<UserFollowersQuery.Data.User.Follower>,
        followUser: @escaping (FollowUserMutation) -> Single<FollowUserMutation.Data.FollowUser>,
        unfollowUser: @escaping (UnfollowUserMutation) -> Single<UnfollowUserMutation.Data.UnfollowUser>
        ) -> Driver<UserFollowersStateObject> {
        
        let queryUserFollowersFeedback: DriverFeedback = react(query: { $0.userFollowersQuery }, effects: composeEffects(shouldQuery: shouldQuery) { query in
            return queryUserFollowers(query)
                .map(Event.onGetUserFollowersData)
                .asSignal(onErrorReturnJust: Event.onGetUserFollowersError)
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
            feedbacks: [uiFeedback, queryUserFollowersFeedback, followUserFeedback, unfollowUserFeedback],
            //            composeStates: { $0.debug("UserFollowersState", trimOutput: false) },
            composeEvents: { $0.debug("UserFollowersState.Event", trimOutput: true) }
        )
    }
}
