//
//  ReputationsStateObject+Event.swift
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

extension ReputationsStateObject {
    
    enum Event {
        case onTriggerReload
        case onTriggerGetMore
        case onGetData(CursorReputationLinksFragment)
        case onGetError(Error)
        
        case onMarkSuccess(String)
        case onMarkError(Error)
        
        case onTriggerShowImage(String)
        case onTriggerShowUser(String)
        case onTriggerPop
    }
}

extension ReputationsStateObject: IsFeedbackStateObject {
    
    func reduce(event: Event, realm: Realm) {
        switch event {
        case .onTriggerReload:
            reputationsQueryState?.reduce(event: .onTriggerReload, realm: realm)
        case .onTriggerGetMore:
            reputationsQueryState?.reduce(event: .onTriggerGetMore, realm: realm)
        case .onGetData(let data):
            reputationsQueryState?.reduce(event: .onGetData(data), realm: realm)
            markReputationsQueryState?.reduce(event: .onTrigger, realm: realm)
        case .onGetError(let error):
            reputationsQueryState?.reduce(event: .onGetError(error), realm: realm)
            
        case .onMarkSuccess(let id):
            markReputationsQueryState?.reduce(event: .onSuccess(id), realm: realm)
        case .onMarkError(let error):
            markReputationsQueryState?.reduce(event: .onError(error), realm: realm)
            
        case .onTriggerShowImage(let mediumId):
            routeState?.reduce(event: .onTriggerShowImage(mediumId), realm: realm)
        case .onTriggerShowUser(let userId):
            routeState?.reduce(event: .onTriggerShowUser(userId), realm: realm)
        case .onTriggerPop:
            routeState?.reduce(event: .onTriggerPop, realm: realm)
        }
    }
}
