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
        case onTriggerSaveMedium
        case onProgress(RxProgress, Int)
        case onSavedMediumSuccess(MediumFragment, Int)
        case onSavedMediumError(Error, Int)
        case onToggleTag(String)
        case onAddTag(String)
        //        case triggerCancel
    }
}

extension CreateImageStateObject: IsFeedbackStateObject {
    
    func reduce(event: Event, realm: Realm) {
        switch event {
        case .onTriggerSaveMedium:
            guard shouldSaveMedium else { return }
            triggerSaveMediumQuery = true
        case .onProgress(let progress, let index):
            saveMediumStates[index].progress?.bytesWritten = Int(progress.bytesWritten)
            saveMediumStates[index].progress?.totalBytes = Int(progress.totalBytes)
            triggerSaveMediumQuery = true // trigger state update
        case .onSavedMediumSuccess(let medium, let index):
            let mediumObject = realm.create(MediumObject.self, value: medium.rawSnapshot, update: true)
            saveMediumStates[index].savedMedium = mediumObject
            finished += 1
            if allFinished {
                triggerSaveMediumQuery = false
                needUpdate?.myInterestedMedia = true
                needUpdate?.myMedia = true
                let failState = saveMediumStates.first(where: { $0.savedError != nil })
                let allSuccess = failState == nil
                if allSuccess {
                    snackbar?.message = "已分享"
                    snackbar?.version = UUID().uuidString
                    popRoute?.version = UUID().uuidString
                } else {
                    snackbar?.message = failState?.savedError
                    snackbar?.version = UUID().uuidString
                }
            }
        case .onSavedMediumError(let error, let index):
            saveMediumStates[index].savedMedium = nil
            saveMediumStates[index].savedError = error.localizedDescription
            finished += 1
            if allFinished {
                triggerSaveMediumQuery = false
                needUpdate?.myInterestedMedia = true
                needUpdate?.myMedia = true
            }
        case .onToggleTag(let tag):
            if let tagState = tagStates.first(where: { $0.tag == tag }) {
                tagState.isSelected = !tagState.isSelected
                if tagState.isSelected { selectedTagHistory?.accept(tag) }
            }
        case .onAddTag(let tag):
            if let tagState = tagStates.first(where: { $0.tag == tag }) {
                tagState.isSelected = true
            } else {
                let newTag = realm.create(TagStateObject.self, value: ["tag": tag])
                newTag.isSelected = true
                tagStates.append(newTag)
            }
            selectedTagHistory?.accept(tag)
        }
    }
}
