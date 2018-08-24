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
        case hotMediaState(CursorMediaStateObject.Event)
        case onTriggerShowImage(String)
    }
}

extension TagMediaStateObject: IsFeedbackStateObject {
    
    func reduce(event: Event, realm: Realm) {
        switch event {
        case .hotMediaState(let event):
            hotMediaState?.reduce(event: event, realm: realm)
        case .onTriggerShowImage(let mediumId):
            routeState?.reduce(event: .onTriggerShowImage(mediumId), realm: realm)
        }
        updateVersion()
    }
}
