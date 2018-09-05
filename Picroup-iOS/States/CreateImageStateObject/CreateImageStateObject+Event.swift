//
//  CreateImageStateObject+Event.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/23.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift
import RxCocoa
import RxAlamofire

extension CreateImageStateObject {
    enum Event {
        case onToggleTag(String)
        case onAddTag(String)
        
        case onTriggerSaveMedium
        case onProgress(RxProgress, Int)
        case onSavedMediumSuccess(MediumFragment, Int)
        case onSavedMediumError(Error, Int)
    }
}

extension CreateImageStateObject: IsFeedbackStateObject {
    
    func reduce(event: Event, realm: Realm) {
        switch event {
        case .onToggleTag(let tag):
            tagsState?.reduce(event: .onToggleTag(tag), realm: realm)
        case .onAddTag(let tag):
            tagsState?.reduce(event: .onAddTag(tag), realm: realm)
            
        case .onTriggerSaveMedium:
            saveImagesQueryState?.reduce(event: .onTrigger, realm: realm)
        case .onProgress(let progress, let index):
            saveImagesQueryState?.reduce(event: .onProgress(progress, index), realm: realm)
        case .onSavedMediumSuccess(let medium, let index):
            saveImagesQueryState?.reduce(event: .onSuccess(medium, index), realm: realm)
            self.onFinishIfNeeded(realm: realm)
        case .onSavedMediumError(let error, let index):
            saveImagesQueryState?.reduce(event: .onError(error, index), realm: realm)
            self.onFinishIfNeeded(realm: realm)
        }
    }
    
    func onFinishIfNeeded(realm: Realm) {
        if saveImagesQueryState?.success != nil {
            snackbar?.reduce(event: .onUpdateMessage("已分享"), realm: realm)
            routeState?.reduce(event: .onTriggerPop, realm: realm)
            needUpdate?.myInterestedMedia = true
            needUpdate?.myMedia = true
        } else if saveImagesQueryState?.error != nil {
            snackbar?.reduce(event: .onUpdateMessage("部分内容分享失败"), realm: realm)
            needUpdate?.myInterestedMedia = true
            needUpdate?.myMedia = true
        }
    }
}
