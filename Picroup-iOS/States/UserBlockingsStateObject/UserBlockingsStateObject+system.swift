//
//  UserBlockingsStateStore.swift
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

extension UserBlockingsStateObject {
    
    func system(
        uiFeedback: @escaping DriverFeedback,
        shouldQuery: @escaping () -> Bool,
        queryUserBlockings: @escaping (UserBlockingUsersQuery) -> Single<[UserFragment]>,
        blockUser: @escaping (BlockUserMutation) -> Single<BlockUserMutation.Data.BlockUser>,
        unblockUser: @escaping (UnblockUserMutation) -> Single<UnblockUserMutation.Data.UnblockUser>
        ) -> Driver<UserBlockingsStateObject> {
        
        let queryUserBlockingsFeedback: DriverFeedback = react(query: { $0.userBlockingsQuery }, effects: composeEffects(shouldQuery: shouldQuery) { query in
            return queryUserBlockings(query)
                .map(Event.onGetUserBlockingsData)
                .asSignal(onErrorReturnJust: Event.onGetUserBlockingsError)
        })
        
        let blockUserFeedback: DriverFeedback = react(query: { $0.blockUserQuery }, effects: composeEffects(shouldQuery: shouldQuery) { query in
            return blockUser(query)
                .map(Event.onBlockUserSuccess)
                .asSignal(onErrorReturnJust: Event.onBlockUserError)
        })
        
        let unblockUserFeedback: DriverFeedback = react(query: { $0.unblockUserQuery }, effects: composeEffects(shouldQuery: shouldQuery) { query in
            return unblockUser(query)
                .map(Event.onUnblockUserSuccess)
                .asSignal(onErrorReturnJust: Event.onUnblockUserError)
        })
        
        return system(
            feedbacks: [uiFeedback, queryUserBlockingsFeedback, blockUserFeedback, unblockUserFeedback],
            //            composeStates: { $0.debug("UserBlockingsState", trimOutput: false) },
            composeEvents: { $0.debug("UserBlockingsState.Event", trimOutput: true) }
        )
    }
}

