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
        case .onTriggerShowImage(let mediumId):
            routeState?.reduce(event: .onTriggerShowImage(mediumId), realm: realm)
        }
    }
}
