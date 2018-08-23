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
            guard shouldStarMedium else { return }
            starMediumVersion = nil
            starMediumError = nil
            triggerStarMediumQuery = true
        case .onStarMediumSuccess(let data):
            medium?.stared.value = true
            medium?.endedAt.value = data.endedAt
            starMediumVersion = UUID().uuidString
            starMediumError = nil
            triggerStarMediumQuery = false
            needUpdate?.myStaredMedia = true
            
            snackbar?.message = "感谢你给图片续命一周"
            snackbar?.version = UUID().uuidString
            
        case .onStarMediumError(let error):
            starMediumVersion = nil
            starMediumError = error.localizedDescription
            triggerStarMediumQuery = false
            
        case .onTriggerDeleteMedium:
            guard shouldDeleteMedium else { return }
            deleteMediumError = nil
            triggerDeleteMediumQuery = true
        case .onDeleteMediumSuccess:
            medium?.delete()
            deleteMediumError = nil
            triggerDeleteMediumQuery = false
            snackbar?.message = "已删除"
            snackbar?.version = UUID().uuidString
            popRoute?.version = UUID().uuidString
        case .onDeleteMediumError(let error):
            deleteMediumError = error.localizedDescription
            triggerDeleteMediumQuery = false
            snackbar?.message = error.localizedDescription
            snackbar?.version = UUID().uuidString
            
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
            snackbar?.message = "已减少类似内容"
            snackbar?.version = UUID().uuidString
            popRoute?.version = UUID().uuidString
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
            loginRoute?.version = UUID().uuidString
        case .onTriggerShowImage(let mediumId):
            imageDetialRoute?.mediumId = mediumId
            imageDetialRoute?.version = UUID().uuidString
        case .onTriggerShowComments(let mediumId):
            imageCommetsRoute?.mediumId = mediumId
            imageCommetsRoute?.version = UUID().uuidString
        case .onTriggerShowTagMedia(let tag):
            tagMediaRoute?.tag = tag
            tagMediaRoute?.version = UUID().uuidString
        case .onTriggerUpdateMediaTags:
            updateMediumTagsRoute?.mediumId = mediumId
            updateMediumTagsRoute?.version = UUID().uuidString
        case .onTriggerShowUser(let userId):
            userRoute?.userId = userId
            userRoute?.version = UUID().uuidString
        case .onTriggerMediumFeedback:
            feedbackRoute?.triggerMedium(mediumId: mediumId)
        case .onTriggerPop:
            popRoute?.version = UUID().uuidString
        }
    }
}
