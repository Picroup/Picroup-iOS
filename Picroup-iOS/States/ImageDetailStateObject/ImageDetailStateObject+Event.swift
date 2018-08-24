//
//  ImageDetailStateObject+Event.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/23.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift
import RxSwift
import RxCocoa
import RxRealm


extension ImageDetailStateObject {
    
    enum Event {
        case onTriggerReloadData
        case onTriggerGetMoreData
        case onGetReloadData(MediumQuery.Data.Medium?)
        case onGetMoreData(MediumQuery.Data.Medium?)
        case onGetError(Error)
        
        case onTriggerStarMedium
        case onStarMediumSuccess(StarMediumMutation.Data.StarMedium)
        case onStarMediumError(Error)
        
        case onTriggerDeleteMedium
        case onDeleteMediumSuccess(String)
        case onDeleteMediumError(Error)
        
        case onTriggerBlockMedium
        case onBlockMediumSuccess(UserFragment)
        case onBlockMediumError(Error)
        
        case onTriggerShareMedium
        case onShareMediumSuccess
        case onShareMediumError(Error)
        
        case onTriggerLogin
        case onTriggerShowImage(String)
        case onTriggerShowComments(String)
        case onTriggerShowTagMedia(String)
        case onTriggerUpdateMediaTags
        case onTriggerShowUser(String)
        case onTriggerMediumFeedback
        case onTriggerPop
    }
}

extension ImageDetailStateObject.Event {
    
    static func onGetData(isReload: Bool) -> (MediumQuery.Data.Medium?) -> ImageDetailStateObject.Event {
        return { isReload ? .onGetReloadData($0) : .onGetMoreData($0) }
    }
}

extension ImageDetailStateObject: IsFeedbackStateObject {
    
    func reduce(event: Event, realm: Realm) {
        switch event {
        case .onTriggerReloadData:
            recommendMedia?.cursor.value = nil
            mediumError = nil
            triggerMediumQuery = true
        case .onTriggerGetMoreData:
            guard shouldQueryMoreRecommendMedia else { return }
            mediumError = nil
            triggerMediumQuery = true
        case .onGetReloadData(let data):
            if let data = data {
                medium = realm.create(MediumObject.self, value: data.rawSnapshot, update: true)
                let fragment = data.recommendedMedia.fragments.cursorMediaFragment
                recommendMedia = CursorMediaObject.create(from: fragment, id: PrimaryKey.recommendMediaId(_id))(realm)
            } else {
                medium?.delete()
                isMediumDeleted = true
            }
            mediumError = nil
            triggerMediumQuery = false
        case .onGetMoreData(let data):
            if let data = data {
                medium = realm.create(MediumObject.self, value: data.snapshot, update: true)
                let fragment = data.recommendedMedia.fragments.cursorMediaFragment
                recommendMedia?.merge(from: fragment)(realm)
            } else {
                medium?.delete()
                isMediumDeleted = true
            }
            mediumError = nil
            triggerMediumQuery = false
        case .onGetError(let error):
            mediumError = error.localizedDescription
            triggerMediumQuery = false
            
        case .onTriggerStarMedium:
            starMediumState?.reduce(event: .onTrigger, realm: realm)
        case .onStarMediumSuccess(let data):
            medium?.reduce(event: .onStared(data.endedAt), realm: realm)
            starMediumState?.reduce(event: .onSuccess(data), realm: realm)
            needUpdate?.myStaredMedia = true
            
            snackbar?.reduce(event: .onUpdateMessage("感谢你给图片续命一周"), realm: realm)
            
        case .onStarMediumError(let error):
            starMediumState?.reduce(event: .onError(error), realm: realm)
            
        case .onTriggerDeleteMedium:
            guard shouldDeleteMedium else { return }
            deleteMediumError = nil
            triggerDeleteMediumQuery = true
        case .onDeleteMediumSuccess:
            medium?.delete()
            deleteMediumError = nil
            triggerDeleteMediumQuery = false
            snackbar?.reduce(event: .onUpdateMessage("已删除"), realm: realm)
            popRoute?.updateVersion()
        case .onDeleteMediumError(let error):
            deleteMediumError = error.localizedDescription
            triggerDeleteMediumQuery = false
            snackbar?.reduce(event: .onUpdateMessage(error.localizedDescription), realm: realm)
            
        case .onTriggerBlockMedium:
            guard shouldBlockMedium else { return }
            blockMediumVersion = nil
            blockMediumError = nil
            triggerBlockMediumQuery = true
        case .onBlockMediumSuccess:
            medium?.delete()
            blockMediumVersion = UUID().uuidString
            blockMediumError = nil
            triggerBlockMediumQuery = false
            snackbar?.reduce(event: .onUpdateMessage("已减少类似内容"), realm: realm)
            popRoute?.updateVersion()
        case .onBlockMediumError(let error):
            blockMediumVersion = nil
            blockMediumError = error.localizedDescription
            triggerBlockMediumQuery = false
            
        case .onTriggerShareMedium:
            triggerShareMediumQuery = true
        case .onShareMediumSuccess:
            triggerShareMediumQuery = false
        case .onShareMediumError(let error):
            shareMediumError = error.localizedDescription
            triggerShareMediumQuery = false
            
        case .onTriggerLogin:
            loginRoute?.updateVersion()
        case .onTriggerShowImage(let mediumId):
            imageDetialRoute?.mediumId = mediumId
            imageDetialRoute?.updateVersion()
        case .onTriggerShowComments(let mediumId):
            imageCommetsRoute?.mediumId = mediumId
            imageCommetsRoute?.updateVersion()
        case .onTriggerShowTagMedia(let tag):
            tagMediaRoute?.tag = tag
            tagMediaRoute?.updateVersion()
        case .onTriggerUpdateMediaTags:
            updateMediumTagsRoute?.mediumId = mediumId
            updateMediumTagsRoute?.updateVersion()
        case .onTriggerShowUser(let userId):
            userRoute?.userId = userId
            userRoute?.updateVersion()
        case .onTriggerMediumFeedback:
            feedbackRoute?.triggerMedium(mediumId: mediumId)
        case .onTriggerPop:
            popRoute?.updateVersion()
        }
        updateVersion()
    }
}
