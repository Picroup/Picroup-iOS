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
            if let tagState = tagStates.first(where: { $0.tag == tag }) {
                tagState.isSelected = !tagState.isSelected
                triggerSyncTagState(tagState)
                if tagState.isSelected { selectedTagHistory?.accept(tag) }
            }
        case .onAddTag(let tag):
            if let tagState = tagStates.first(where: { $0.tag == tag }), !tagState.isSelected {
                tagState.isSelected = true
                triggerSyncTagState(tagState)
            } else {
                let newTag = realm.create(TagStateObject.self, value: ["tag": tag])
                newTag.isSelected = true
                triggerSyncTagState(newTag)
                tagStates.append(newTag)
            }
            selectedTagHistory?.accept(tag)
        case .onAddTagSuccess(let data):
            medium = realm.create(MediumObject.self, value: data.rawSnapshot, update: true)
            addTagError = nil
            triggerAddTagQuery = false
        case .onAddTagError(let error, let tag):
            tagStates.first(where: { $0.tag == tag })?.isSelected = false
            addTagError = error.localizedDescription
            triggerAddTagQuery = false
        case .onRemoveTagSuccess(let data):
            medium = realm.create(MediumObject.self, value: data.rawSnapshot, update: true)
            removeTagError = nil
            triggerRemoveTagQuery = false
        case .onRemoveTagError(let error, let tag):
            tagStates.first(where: { $0.tag == tag })?.isSelected = true
            removeTagError = error.localizedDescription
            triggerRemoveTagQuery = false
        }
    }
    
    func triggerSyncTagState(_ tagState: TagStateObject) {
        if tagState.isSelected {
            addTag = tagState.tag
            addTagError = nil
            triggerAddTagQuery = true
        } else {
            removeTag = tagState.tag
            removeTagError = nil
            triggerRemoveTagQuery = true
        }
    }
}
