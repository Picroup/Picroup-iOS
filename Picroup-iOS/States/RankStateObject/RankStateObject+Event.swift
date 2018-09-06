//
//  RankStateObject+Event.swift
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

extension RankStateObject {
    
    enum Event {
        case onTriggerReloadHotMedia
        case onTriggerGetMoreHotMedia
        case onGetHotMediaData(CursorMediaFragment)
        case onGetHotMediaError(Error)
        
        case onToggleTag(String)
        case onTriggerLogin
        case onTriggerShowImage(String)
    }
}

extension RankStateObject: IsFeedbackStateObject {
    
    func reduce(event: Event, realm: Realm) {
        switch event {
        case .onTriggerReloadHotMedia:
            hotMediaQueryState?.reduce(event: .onTriggerReload, realm: realm)
        case .onTriggerGetMoreHotMedia:
            hotMediaQueryState?.reduce(event: .onTriggerGetMore, realm: realm)
        case .onGetHotMediaData(let data):
            hotMediaQueryState?.reduce(event: .onGetSampleData(data), realm: realm)
        case .onGetHotMediaError(let error):
            hotMediaQueryState?.reduce(event: .onGetError(error), realm: realm)
            
        case .onToggleTag(let tag):
            hotMediaTagsState?.reduce(event: .onToggleTag(tag), realm: realm)
            hotMediaQueryState?.reduce(event: .onTriggerReload, realm: realm)
        case .onTriggerLogin:
            routeState?.reduce(event: .onTriggerLogin, realm: realm)
        case .onTriggerShowImage(let mediumId):
            routeState?.reduce(event: .onTriggerShowImage(mediumId), realm: realm)
        }
    }
}
