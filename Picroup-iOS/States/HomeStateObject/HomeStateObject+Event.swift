//
//  HomeStateObject+Event.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/23.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift
import RxSwift
import RxCocoa


extension HomeStateObject {
    
    enum Event {
        
        case myInterestedMediaState(CursorMediaStateObject.Event)
        case onTriggerReloadMyInterestedMediaIfNeeded
        
        case onTriggerShowImage(String)
        case onTriggerShowComments(String)
        case onTriggerShowUser(String)
        
        case onTriggerCreateImage([MediumItem])
        case onTriggerSearchUser
    }
}

extension HomeStateObject: IsFeedbackStateObject {
    
    func reduce(event: Event, realm: Realm) {
        switch event {
        case .myInterestedMediaState(let event):
            myInterestedMediaState?.reduce(event: event, realm: realm)
        case .onTriggerReloadMyInterestedMediaIfNeeded:
            guard needUpdate?.myInterestedMedia == true else { return }
            needUpdate?.myInterestedMedia = false
            myInterestedMediaState?.reduce(event: .onTriggerReload, realm: realm)
            
        case .onTriggerShowImage(let mediumId):
            imageDetialRoute?.mediumId = mediumId
            imageDetialRoute?.version = UUID().uuidString
        case .onTriggerShowComments(let mediumId):
            imageCommetsRoute?.mediumId = mediumId
            imageCommetsRoute?.version = UUID().uuidString
        case .onTriggerShowUser(let userId):
            userRoute?.userId = userId
            userRoute?.version = UUID().uuidString
            
        case .onTriggerCreateImage(let mediaItems):
            createImageRoute?.mediaItemObjects.removeAll()
            let mediaItemObjects = mediaItems.map { MediaItemObject.create(mediaItem: $0)(realm) }
            createImageRoute?.mediaItemObjects.append(objectsIn: mediaItemObjects)
            createImageRoute?.version = UUID().uuidString
        case .onTriggerSearchUser:
            searchUserRoute?.version = UUID().uuidString
        }
        version = UUID().uuidString
    }
}
