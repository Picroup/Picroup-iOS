//
//  RouteStateObject+Event.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/24.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift
import RxSwift
import RxCocoa

extension RouteStateObject {
    
    enum Event {
        case onTriggerShowImage(String)
        case onTriggerShowComments(String)
        case onTriggerShowTagMedia(String)
        case onTriggerUpdateMediaTags(String)
        case onTriggerShowReputations
        case onTriggerCreateImage([MediumItem])
        
        case onTriggerShowUser(String)
        case onTriggerUpdateUser
        case onTriggerShowUserFollowings(String)
        case onTriggerShowUserFollowers(String)
        case onTriggerSearchUser
        case onTriggerShowUserBlockings
        
        case onTriggerLogin
        case onTriggerResetPassword
        case onTriggerBackToLogin
        case onTriggerAppFeedback
        case onTriggerMediumFeedback(String)
        case onTriggerUserFeedback(String)
        case onTriggerAboutApp
        
//        case onLogout
        
        case onTriggerPop
    }
}

extension RouteStateObject: IsFeedbackStateObject {
    
    func reduce(event: Event, realm: Realm) {
        switch event {
        case .onTriggerShowImage(let mediumId):
            imageDetialRoute?.mediumId = mediumId
            imageDetialRoute?.updateVersion()
        case .onTriggerShowComments(let mediumId):
            imageCommetsRoute?.mediumId = mediumId
            imageCommetsRoute?.updateVersion()
        case .onTriggerShowTagMedia(let tag):
            tagMediaRoute?.tag = tag
            tagMediaRoute?.updateVersion()
        case .onTriggerUpdateMediaTags(let mediumId):
            updateMediumTagsRoute?.mediumId = mediumId
            updateMediumTagsRoute?.updateVersion()
        case .onTriggerShowReputations:
            reputationsRoute?.updateVersion()
        case .onTriggerCreateImage(let mediaItems):
            createImageRoute?.mediaItemObjects.removeAll()
            let mediaItemObjects = mediaItems.map { MediaItemObject.create(mediaItem: $0)(realm) }
            createImageRoute?.mediaItemObjects.append(objectsIn: mediaItemObjects)
            createImageRoute?.updateVersion()
            
        case .onTriggerShowUser(let userId):
            userRoute?.userId = userId
            userRoute?.updateVersion()
        case .onTriggerUpdateUser:
            updateUserRoute?.updateVersion()
        case .onTriggerShowUserFollowings(let userId):
            userFollowingsRoute?.userId = userId
            userFollowingsRoute?.updateVersion()
        case .onTriggerShowUserFollowers(let userId):
            userFollowersRoute?.userId = userId
            userFollowersRoute?.updateVersion()
        case .onTriggerSearchUser:
            searchUserRoute?.updateVersion()
        case .onTriggerShowUserBlockings:
            userBlockingsRoute?.updateVersion()
            
        case .onTriggerLogin:
            loginRoute?.updateVersion()
        case .onTriggerResetPassword:
            resetPasswordRoute?.updateVersion()
        case .onTriggerBackToLogin:
            backToLoginRoute?.updateVersion()
        case .onTriggerAppFeedback:
            feedbackRoute?.triggerApp()
        case .onTriggerMediumFeedback(let mediumId):
            feedbackRoute?.triggerMedium(mediumId: mediumId)
        case .onTriggerUserFeedback(let userId):
            feedbackRoute?.triggerUser(toUserId: userId)
        case .onTriggerAboutApp:
            aboutAppRoute?.updateVersion()
        case .onTriggerPop:
            popRoute?.updateVersion()
        }
    }
}
