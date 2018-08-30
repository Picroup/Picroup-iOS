//
//  FeedbackStateObject+Event.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/23.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift
import RxSwift
import RxCocoa

extension FeedbackStateObject {
    
    enum Event {
        
        case onTriggerSaveFeedback
        case onSaveFeedbackSuccess(String)
        case onSaveFeedbackError(Error)
        
        case onChangeContent(String)
        
        case onTriggerPop
    }
}

extension FeedbackStateObject: IsFeedbackStateObject {
    
    func reduce(event: Event, realm: Realm) {
        switch event {
        case .onTriggerSaveFeedback:
            saveFeedbackQueryState?.reduce(event: .onTrigger, realm: realm)
        case .onSaveFeedbackSuccess(let data):
            saveFeedbackQueryState?.reduce(event: .onSuccess(data), realm: realm)
            snackbar?.reduce(event: .onUpdateMessage("已提交"), realm: realm)
            routeState?.reduce(event: .onTriggerPop, realm: realm)
        case .onSaveFeedbackError(let error):
            saveFeedbackQueryState?.reduce(event: .onError(error), realm: realm)
            snackbar?.reduce(event: .onUpdateMessage(error.localizedDescription), realm: realm)
        case .onChangeContent(let content):
            saveFeedbackQueryState?.reduce(event: .onChangeContent(content), realm: realm)
        case .onTriggerPop:
            routeState?.reduce(event: .onTriggerPop, realm: realm)
        }
    }
}
