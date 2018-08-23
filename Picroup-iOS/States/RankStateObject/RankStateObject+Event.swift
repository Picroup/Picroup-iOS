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
        case hotMediaState(CursorMediaStateObject.Event)
        case onToggleTag(String)
        case onTriggerLogin
        case onTriggerShowImage(String)
    }
}

extension RankStateObject: IsFeedbackStateObject {
    
    func reduce(event: Event, realm: Realm) {
        switch event {
        case .hotMediaState(let event):
            hotMediaState?.reduce(event: event, realm: realm)
        case .onToggleTag(let tag):
            tagStates.forEach { tagState in
                if tagState.tag == tag {
                    tagState.isSelected = !tagState.isSelected
                    if tagState.isSelected { selectedTagHistory?.accept(tag) }
                } else {
                    tagState.isSelected = false
                }
            }
            hotMediaState?.reduce(event: .onTriggerReload, realm: realm)
        case .onTriggerLogin:
            loginRoute?.version = UUID().uuidString
        case .onTriggerShowImage(let mediumId):
            imageDetialRoute?.mediumId = mediumId
            imageDetialRoute?.version = UUID().uuidString
        }
        updateVersion()
    }
}
