//
//  AppStateObject+Event.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/23.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift

extension AppStateObject {
    
    enum Event {
        case onTriggerReloadMe
        case onGetMeSuccess(UserDetailFragment)
        case onGetMeError(Error)
        case onViewMedium(String)
        case onRecommendMediumCompleted
    }
}

extension AppStateObject: IsFeedbackStateObject {
    
    func reduce(event: Event, realm: Realm) {
        switch event {
        case .onTriggerReloadMe:
            meError = nil
            triggerMeQuery = true
        case .onGetMeSuccess(let data):
            guard sessionState?.isLogin == true else { return }
            sessionState?.reduce(event: .onCreateUser(data), realm: realm)

            meError = nil
            triggerMeQuery = false
        case .onGetMeError(let error):
            meError = error.localizedDescription
            triggerMeQuery = false
            
        case .onViewMedium(let mediumId):
            previousMediumId = currentMediumId
            currentMediumId = mediumId
            triggerRecommendMedium = true
        case  .onRecommendMediumCompleted:
            triggerRecommendMedium = false
        }
    }
}
