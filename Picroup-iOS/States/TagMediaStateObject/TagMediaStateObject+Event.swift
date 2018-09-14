//
//  TagMediaStateObject+Event.swift
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

extension TagMediaStateObject {
    
    enum Event {
        case onTriggerReloadHotMedia
        case onTriggerGetMoreHotMedia
        case onGetHotMediaData(CursorMediaFragment)
        case onGetHotMediaError(Error)
        
        case onTriggerStarMedium(String)
        case onStarMediumSuccess(StarMediumMutation.Data.StarMedium)
        case onStarMediumError(Error)
        
        case onTriggerShowImage(String)
    }
}

extension TagMediaStateObject: IsFeedbackStateObject {
    
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
            
        case .onTriggerStarMedium(let mediumId):
            guard sessionState?.isLogin == true else {
                routeState?.reduce(event: .onTriggerLogin, realm: realm)
                return
            }
            starMediumQueryState?.reduce(event: .onTrigger(mediumId), realm: realm)
        case .onStarMediumSuccess(let data):
            starMediumQueryState?.reduce(event: .onSuccess(data), realm: realm)
            needUpdate?.myStaredMedia = true
            snackbar?.reduce(event: .onUpdateMessage("感谢你给媒体续命一周"), realm: realm)
        case .onStarMediumError(let error):
            starMediumQueryState?.reduce(event: .onError(error), realm: realm)
            snackbar?.reduce(event: .onUpdateMessage(error.localizedDescription), realm: realm)
            
        case .onTriggerShowImage(let mediumId):
            routeState?.reduce(event: .onTriggerShowImage(mediumId), realm: realm)
        }
    }
}
