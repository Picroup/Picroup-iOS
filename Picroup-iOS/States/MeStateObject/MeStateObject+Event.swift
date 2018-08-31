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
        case onChangeSelectedTab(MeTabStateObject.Tab)
        
        case onTriggerReloadMyMediaIfNeeded
        case onTriggerReloadMyMedia
        case onTriggerGetMoreMyMedia
        case onGetMyMediaData(CursorMediaFragment)
        case onGetMyMediaError(Error)

        case onTriggerReloadMyStaredMediaIfNeeded
        case onTriggerReloadMyStaredMedia
        case onTriggerGetMoreMyStaredMedia
        case onGetMyStaredMediaData(CursorMediaFragment)
        case onGetMyStaredMediaError(Error)

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
            tabState?.reduce(event: .onChangeSelectedTab(tab), realm: realm)
            
        case .onTriggerReloadMyMediaIfNeeded:
            guard needUpdate?.myMedia == true else { return }
            needUpdate?.myMedia = false
            myMediaQueryState?.reduce(event: .onTriggerReload, realm: realm)
        case .onTriggerReloadMyMedia:
            myMediaQueryState?.reduce(event: .onTriggerReload, realm: realm)
        case .onTriggerGetMoreMyMedia:
            myMediaQueryState?.reduce(event: .onTriggerGetMore, realm: realm)
        case .onGetMyMediaData(let data):
            myMediaQueryState?.reduce(event: .onGetData(data), realm: realm)
        case .onGetMyMediaError(let error):
            myMediaQueryState?.reduce(event: .onGetError(error), realm: realm)
            
        case .onTriggerReloadMyStaredMediaIfNeeded:
            guard needUpdate?.myStaredMedia == true else { return }
            needUpdate?.myStaredMedia = false
            myStaredMediaQueryState?.reduce(event: .onTriggerReload, realm: realm)
        case .onTriggerReloadMyStaredMedia:
            myStaredMediaQueryState?.reduce(event: .onTriggerReload, realm: realm)
        case .onTriggerGetMoreMyStaredMedia:
            myStaredMediaQueryState?.reduce(event: .onTriggerGetMore, realm: realm)
        case .onGetMyStaredMediaData(let data):
            myStaredMediaQueryState?.reduce(event: .onGetData(data), realm: realm)
        case .onGetMyStaredMediaError(let error):
            myStaredMediaQueryState?.reduce(event: .onGetError(error), realm: realm)
            
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
            sessionState?.reduce(event: .onLogout, realm: realm)
        }
    }
}
