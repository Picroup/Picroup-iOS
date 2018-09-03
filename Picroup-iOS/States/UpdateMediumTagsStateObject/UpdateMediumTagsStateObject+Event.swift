//
//  UpdateMediumTagsStateObject+Event.swift
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
import RxAlamofire

extension UpdateMediumTagsStateObject {
    enum Event {
        case onToggleTag(String)
        case onAddTag(String)
        
        case onAddTagSuccess(MediumFragment)
        case onAddTagError(Error, String)
        
        case onRemoveTagSuccess(MediumFragment)
        case onRemoveTagError(Error, String)
    }
}

extension UpdateMediumTagsStateObject: IsFeedbackStateObject {
    
    func reduce(event: Event, realm: Realm) {
        switch event {
        case .onToggleTag(let tag):
            tagsState?.reduce(event: .onToggleTag(tag), realm: realm)
            if let tagState = tagsState?.tagStates.first(where: { $0.tag == tag }) {
                triggerSyncTagState(tagState, realm: realm)
            }
        case .onAddTag(let tag):
            tagsState?.reduce(event: .onAddTag(tag), realm: realm)
            if let tagState = tagsState?.tagStates.first(where: { $0.tag == tag }) {
                triggerSyncTagState(tagState, realm: realm)
            }
            
        case .onAddTagSuccess(let data):
            addTagQueryState?.reduce(event: .onSuccess(data), realm: realm)
        case .onAddTagError(let error, let tag):
            tagsState?.reduce(event: .onToggleTag(tag), realm: realm)
            addTagQueryState?.reduce(event: .onError(error), realm: realm)
            
        case .onRemoveTagSuccess(let data):
            removeTagQueryState?.reduce(event: .onSuccess(data), realm: realm)
        case .onRemoveTagError(let error, let tag):
            tagsState?.reduce(event: .onToggleTag(tag), realm: realm)
            removeTagQueryState?.reduce(event: .onError(error), realm: realm)
        }
    }
    
    func triggerSyncTagState(_ tagState: TagStateObject, realm: Realm) {
        if tagState.isSelected {
            addTagQueryState?.reduce(event: .onTriggerAddTag(tagState.tag), realm: realm)
        } else {
            removeTagQueryState?.reduce(event: .onTriggerRemoveTag(tagState.tag), realm: realm)
        }
    }
}
