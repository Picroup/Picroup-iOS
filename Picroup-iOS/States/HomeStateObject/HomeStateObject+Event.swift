//
//  HomeStateObject+Event.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/23.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift
import RxSwift
import RxCocoa


extension HomeStateObject {
    
    enum Event {
        
        case myInterestedMediaState(CursorMediaStateObject.Event)
        case onTriggerReloadMyInterestedMediaIfNeeded
        
        case onTriggerShowImage(String)
        case onTriggerShowComments(String)
        case onTriggerShowUser(String)
        case onTriggerCreateImage([MediumItem])
        case onTriggerSearchUser
    }
}

extension HomeStateObject: IsFeedbackStateObject {
    
    func reduce(event: Event, realm: Realm) {
        switch event {
        case .myInterestedMediaState(let event):
            myInterestedMediaState?.reduce(event: event, realm: realm)
        case .onTriggerReloadMyInterestedMediaIfNeeded:
            guard needUpdate?.myInterestedMedia == true else { return }
            needUpdate?.myInterestedMedia = false
            myInterestedMediaState?.reduce(event: .onTriggerReload, realm: realm)
            
        case .onTriggerShowImage(let mediumId):
            routeState?.reduce(event: .onTriggerShowImage(mediumId), realm: realm)
        case .onTriggerShowComments(let mediumId):
            routeState?.reduce(event: .onTriggerShowComments(mediumId), realm: realm)
        case .onTriggerShowUser(let userId):
            routeState?.reduce(event: .onTriggerShowUser(userId), realm: realm)
        case .onTriggerCreateImage(let mediaItems):
            routeState?.reduce(event: .onTriggerCreateImage(mediaItems), realm: realm)
        case .onTriggerSearchUser:
            routeState?.reduce(event: .onTriggerSearchUser, realm: realm)
        }
        updateVersion()
    }
}
