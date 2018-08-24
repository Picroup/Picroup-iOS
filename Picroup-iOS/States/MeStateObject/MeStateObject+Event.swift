//
//  MeStateObject+Event.swift
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

extension MeStateObject {
    
    enum Event {
        case onChangeSelectedTab(Tab)
        
        case myMediaState(CursorMediaStateObject.Event)
        case onTriggerReloadMyMediaIfNeeded
        
        case myStaredMediaState(CursorMediaStateObject.Event)
        case onTriggerReloadMyStaredMediaIfNeeded
        
        case onTriggerShowImage(String)
        case onTriggerShowReputations
        case onTriggerShowUserFollowings
        case onTriggerShowUserFollowers
        case onTriggerShowUserBlockings
        case onTriggerUpdateUser
        case onTriggerAppFeedback
        case onTriggerAboutApp
        case onTriggerPop
        case onLogout
    }
}

extension MeStateObject: IsFeedbackStateObject {
    
    func reduce(event: Event, realm: Realm) {
        switch event {
        case .onChangeSelectedTab(let tab):
            selectedTabIndex = tab.rawValue
            
        case .myMediaState(let event):
            myMediaState?.reduce(event: event, realm: realm)
        case .onTriggerReloadMyMediaIfNeeded:
            guard needUpdate?.myMedia == true else { return }
            needUpdate?.myMedia = false
            myMediaState?.reduce(event: .onTriggerReload, realm: realm)
            
        case .myStaredMediaState(let event):
            myStaredMediaState?.reduce(event: event, realm: realm)
        case .onTriggerReloadMyStaredMediaIfNeeded:
            guard needUpdate?.myStaredMedia == true else { return }
            needUpdate?.myStaredMedia = false
            myStaredMediaState?.reduce(event: .onTriggerReload, realm: realm)
            
        case .onTriggerShowImage(let mediumId):
            imageDetialRoute?.mediumId = mediumId
            imageDetialRoute?.updateVersion()
        case .onTriggerShowReputations:
            reputationsRoute?.updateVersion()
        case .onTriggerShowUserFollowings:
            userFollowingsRoute?.userId = session?.currentUserId
            userFollowingsRoute?.updateVersion()
        case .onTriggerShowUserFollowers:
            userFollowersRoute?.userId = session?.currentUserId
            userFollowersRoute?.updateVersion()
        case .onTriggerShowUserBlockings:
            userBlockingsRoute?.updateVersion()
        case .onTriggerUpdateUser:
            updateUserRoute?.updateVersion()
        case .onTriggerAppFeedback:
            feedbackRoute?.triggerApp()
        case .onTriggerAboutApp:
            aboutAppRoute?.updateVersion()
        case .onTriggerPop:
            popRoute?.updateVersion()
        case .onLogout:
            session?.currentUser = nil
            realm.delete(realm.objects(UserObject.self))
            realm.delete(realm.objects(MediumObject.self))
            realm.delete(realm.objects(NotificationObject.self))
            realm.delete(realm.objects(ReputationObject.self))
        }
        updateVersion()
    }
}
