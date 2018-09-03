//
//  UpdateUserStateStore.swift
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
import RxAlamofire
import RxFeedback

extension UpdateUserStateObject {
    
    func system(
        uiFeedback: @escaping DriverFeedback,
        shouldQuery: @escaping () -> Bool,
        querySetAvatar: @escaping (UserSetAvatarQueryStateObject.Query) -> Single<UserFragment>,
        querySetDisplayName: @escaping (UserSetDisplayNameQuery) -> Single<UserFragment>
        ) -> Driver<UpdateUserStateObject> {
        
        let querySetAvatarFeedback: DriverFeedback = react(query: { $0.setAvatarQuery }, effects: composeEffects(shouldQuery: shouldQuery) { query in
            return querySetAvatar(query)
                .map(Event.onSetAvatarIdSuccess)
                .asSignal(onErrorReturnJust: Event.onSetAvatarIdError)
        })
        
        let querySetDisplayNameFeedback: DriverFeedback = react(query: { $0.setDisplayNameQuery }, effects: composeEffects(shouldQuery: shouldQuery) { query in
            return querySetDisplayName(query)
                .map(Event.onSetDisplayNameSuccess)
                .asSignal(onErrorReturnJust: Event.onSetDisplayNameError)
        })
        
        return system(
            feedbacks: [uiFeedback, querySetAvatarFeedback, querySetDisplayNameFeedback],
            //            composeStates: { $0.debug("UpdateUserState", trimOutput: false) },
            composeEvents: { $0.debug("UpdateUserState.Event", trimOutput: true) }
        )
    }
}

