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
        case onGetData(MediumQuery.Data.Medium?)
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

extension ImageDetailStateObject: IsFeedbackStateObject {
    
    func reduce(event: Event, realm: Realm) {
        switch event {
        case .onTriggerReloadData:
            mediumQueryState?.reduce(event: .onTriggerReload, realm: realm)
        case .onTriggerGetMoreData:
            mediumQueryState?.reduce(event: .onTriggerGetMore, realm: realm)
        case .onGetData(let data):
            mediumQueryState?.reduce(event: .onGetData(data), realm: realm)
        case .onGetError(let error):
            mediumQueryState?.reduce(event: .onGetError(error), realm: realm)
            snackbar?.reduce(event: .onUpdateMessage(error.localizedDescription), realm: realm)
            
        case .onTriggerStarMedium:
            starMediumQueryState?.reduce(event: .onTrigger, realm: realm)
        case .onStarMediumSuccess(let data):
            mediumQueryState?.medium?.reduce(event: .onStared(data.endedAt), realm: realm)
            starMediumQueryState?.reduce(event: .onSuccess(""), realm: realm)
            needUpdate?.myStaredMedia = true
            snackbar?.reduce(event: .onUpdateMessage("感谢你给图片续命一周"), realm: realm)
        case .onStarMediumError(let error):
            starMediumQueryState?.reduce(event: .onError(error), realm: realm)
            snackbar?.reduce(event: .onUpdateMessage(error.localizedDescription), realm: realm)

        case .onTriggerDeleteMedium:
            deleteMediumQueryState?.reduce(event: .onTrigger, realm: realm)
        case .onDeleteMediumSuccess:
            mediumQueryState?.reduce(event: .onDeleteMedium, realm: realm)
            deleteMediumQueryState?.reduce(event: .onSuccess(""), realm: realm)
            routeState?.reduce(event: .onTriggerPop, realm: realm)
            snackbar?.reduce(event: .onUpdateMessage("已删除"), realm: realm)
        case .onDeleteMediumError(let error):
            deleteMediumQueryState?.reduce(event: .onError(error), realm: realm)
            snackbar?.reduce(event: .onUpdateMessage(error.localizedDescription), realm: realm)
            
        case .onTriggerBlockMedium:
            blockMediumQueryState?.reduce(event: .onTrigger, realm: realm)
        case .onBlockMediumSuccess:
            mediumQueryState?.reduce(event: .onDeleteMedium, realm: realm)
            blockMediumQueryState?.reduce(event: .onSuccess(""), realm: realm)
            routeState?.reduce(event: .onTriggerPop, realm: realm)
            snackbar?.reduce(event: .onUpdateMessage("已减少类似内容"), realm: realm)
        case .onBlockMediumError(let error):
            blockMediumQueryState?.reduce(event: .onError(error), realm: realm)
            snackbar?.reduce(event: .onUpdateMessage(error.localizedDescription), realm: realm)
            
        case .onTriggerShareMedium:
            shareMediumQueryState?.reduce(event: .onTrigger, realm: realm)
        case .onShareMediumSuccess:
            shareMediumQueryState?.reduce(event: .onSuccess(""), realm: realm)
        case .onShareMediumError(let error):
            shareMediumQueryState?.reduce(event: .onError(error), realm: realm)
            snackbar?.reduce(event: .onUpdateMessage(error.localizedDescription), realm: realm)
            
        case .onTriggerLogin:
            routeState?.reduce(event: .onTriggerLogin, realm: realm)
        case .onTriggerShowImage(let mediumId):
            routeState?.reduce(event: .onTriggerShowImage(mediumId), realm: realm)
        case .onTriggerShowComments(let mediumId):
            routeState?.reduce(event: .onTriggerShowComments(mediumId), realm: realm)
        case .onTriggerShowTagMedia(let tag):
            routeState?.reduce(event: .onTriggerShowTagMedia(tag), realm: realm)
        case .onTriggerUpdateMediaTags:
            routeState?.reduce(event: .onTriggerUpdateMediaTags(mediumId), realm: realm)
        case .onTriggerShowUser(let userId):
            routeState?.reduce(event: .onTriggerShowUser(userId), realm: realm)
        case .onTriggerMediumFeedback:
            routeState?.reduce(event: .onTriggerMediumFeedback(mediumId), realm: realm)
        case .onTriggerPop:
            routeState?.reduce(event: .onTriggerPop, realm: realm)
        }
    }
}
