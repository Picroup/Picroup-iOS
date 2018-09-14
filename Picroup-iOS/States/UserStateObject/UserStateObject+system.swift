//
//  UserStateStore.swift
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

extension UserStateObject {
    
    func system(
        uiFeedback: @escaping DriverFeedback,
        shouldQuery: @escaping () -> Bool,
        queryUser: @escaping (UserQuery) -> Single<UserQuery.Data.User>,
        queryUserMedia: @escaping (MyMediaQuery) -> Single<CursorMediaFragment>,
        followUser: @escaping (FollowUserMutation) -> Single<FollowUserMutation.Data.FollowUser>,
        unfollowUser: @escaping (UnfollowUserMutation) -> Single<UnfollowUserMutation.Data.UnfollowUser>,
        blockUser: @escaping (BlockUserMutation) -> Single<BlockUserMutation.Data.BlockUser>,
        starMedium: @escaping (StarMediumMutation) -> Single<StarMediumMutation.Data.StarMedium>
        ) -> Driver<UserStateObject> {
        
        let queryUserFeedback: DriverFeedback = react(query: { $0.userQuery }, effects: composeEffects(shouldQuery: shouldQuery) { query in
            return queryUser(query)
                .map(Event.onGetUserSuccess)
                .asSignal(onErrorReturnJust: Event.onGetUserError)
        })
        
        let queryUserMediaFeedback: DriverFeedback = react(query: { $0.userMediaQuery }, effects: composeEffects(shouldQuery: shouldQuery) { query in
            return queryUserMedia(query)
                .map(Event.onGetUserMediaData)
                .asSignal(onErrorReturnJust: Event.onGetUserMediaError)
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
        
        let blockUserFeedback: DriverFeedback = react(query: { $0.blockUserQuery }, effects: composeEffects(shouldQuery: shouldQuery) { query in
            return blockUser(query)
                .map(Event.onBlockUserSuccess)
                .asSignal(onErrorReturnJust: Event.onBlockUserError)
        })
        
        let starMediumFeedback: DriverFeedback = react(query: { $0.starMediumQuery }, effects: composeEffects(shouldQuery: shouldQuery) { query in
            return starMedium(query)
                .map(Event.onStarMediumSuccess)
                .asSignal(onErrorReturnJust: Event.onStarMediumError)
        })
        
        return system(
            feedbacks: [uiFeedback, queryUserFeedback, queryUserMediaFeedback, followUserFeedback, unfollowUserFeedback, blockUserFeedback, starMediumFeedback],
            //            composeStates: { $0.debug("UserState", trimOutput: false) },
            composeEvents: { $0.debug("UserState.Event", trimOutput: true) }
        )
    }
}

