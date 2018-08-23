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
            guard shouldSaveFeedback else { return }
            savedFeedbackId = nil
            savedFeedbackError = nil
            triggerSaveFeedback = true
        case .onSaveFeedbackSuccess(let data):
            savedFeedbackId = data
            savedFeedbackError = nil
            triggerSaveFeedback = false
            content = ""
            
            snackbar?.message = "已提交"
            snackbar?.version = UUID().uuidString
            popRoute?.version = UUID().uuidString
        case .onSaveFeedbackError(let error):
            savedFeedbackId = nil
            savedFeedbackError = error.localizedDescription
            triggerSaveFeedback = false
            
            snackbar?.message = error.localizedDescription
            snackbar?.version = UUID().uuidString
        case .onChangeContent(let content):
            self.content = content
        case .onTriggerPop:
            popRoute?.version = UUID().uuidString
        }
    }
}
