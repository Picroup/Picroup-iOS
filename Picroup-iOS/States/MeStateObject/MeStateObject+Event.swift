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
            routeState?.reduce(event: .onTriggerShowImage(mediumId), realm: realm)
        case .onTriggerShowReputations:
            routeState?.reduce(event: .onTriggerShowReputations, realm: realm)
        case .onTriggerShowUserFollowings:
            routeState?.reduce(event: .onTriggerShowUserFollowings(sessionState?.currentUserId), realm: realm)
        case .onTriggerShowUserFollowers:
            routeState?.reduce(event: .onTriggerShowUserFollowers(sessionState?.currentUserId), realm: realm)
        case .onTriggerShowUserBlockings:
            routeState?.reduce(event: .onTriggerShowUserBlockings, realm: realm)
        case .onTriggerUpdateUser:
            routeState?.reduce(event: .onTriggerUpdateUser, realm: realm)
        case .onTriggerAppFeedback:
            routeState?.reduce(event: .onTriggerAppFeedback, realm: realm)
        case .onTriggerAboutApp:
            routeState?.reduce(event: .onTriggerAboutApp, realm: realm)
        case .onTriggerPop:
            routeState?.reduce(event: .onTriggerPop, realm: realm)
        case .onLogout:
            sessionState?.reduce(event: .onRemoveUser, realm: realm)
            realm.delete(realm.objects(UserObject.self))
            realm.delete(realm.objects(MediumObject.self))
            realm.delete(realm.objects(NotificationObject.self))
            realm.delete(realm.objects(ReputationObject.self))
        }
        updateVersion()
    }
}
