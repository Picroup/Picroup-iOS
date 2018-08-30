//
//  UserFollowingsStateStore.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/23.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxFeedback

extension UserFollowingsStateObject {
    
    func system(
        uiFeedback: @escaping DriverFeedback,
        shouldQuery: @escaping () -> Bool,
        queryUserFollowings: @escaping (UserFollowingsQuery) -> Single<UserFollowingsQuery.Data.User.Following>,
        followUser: @escaping (FollowUserMutation) -> Single<FollowUserMutation.Data.FollowUser>,
        unfollowUser: @escaping (UnfollowUserMutation) -> Single<UnfollowUserMutation.Data.UnfollowUser>
        ) -> Driver<UserFollowingsStateObject> {
        
        let queryUserFollowingsFeedback: DriverFeedback = react(query: { $0.userFollowingsQuery }, effects: composeEffects(shouldQuery: shouldQuery) { query in
            return queryUserFollowings(query)
                .map(Event.onGetUserFollowingsData)
                .asSignal(onErrorReturnJust: Event.onGetUserFollowingsError)
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
            feedbacks: [uiFeedback, queryUserFollowingsFeedback, followUserFeedback, unfollowUserFeedback],
            //            composeStates: { $0.debug("UserFollowingsState", trimOutput: false) },
            composeEvents: { $0.debug("UserFollowingsState.Event", trimOutput: true) }
        )
    }
}
