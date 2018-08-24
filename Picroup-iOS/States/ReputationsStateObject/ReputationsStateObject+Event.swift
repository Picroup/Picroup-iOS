//
//  ReputationsStateObject+Event.swift
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

extension ReputationsStateObject {
    
    enum Event {
        case onTriggerReload
        case onTriggerGetMore
        case onGetReloadData(CursorReputationLinksFragment)
        case onGetMoreData(CursorReputationLinksFragment)
        case onGetError(Error)
        case onMarkSuccess(String)
        case onMarkError(Error)
        case onTriggerShowImage(String)
        case onTriggerShowUser(String)
        case onTriggerPop
    }
}

extension ReputationsStateObject.Event {
    
    static func onGetData(isReload: Bool) -> (CursorReputationLinksFragment) -> ReputationsStateObject.Event {
        return { isReload ? .onGetReloadData($0) : .onGetMoreData($0) }
    }
}

extension ReputationsStateObject: IsFeedbackStateObject {
    
    func reduce(event: Event, realm: Realm) {
        switch event {
        case .onTriggerReload:
            reputations?.cursor.value = nil
            reputationsError = nil
            triggerReputationsQuery = true
        case .onTriggerGetMore:
            guard shouldQueryMoreReputations else { return }
            reputationsError = nil
            triggerReputationsQuery = true
        case .onGetReloadData(let data):
            reputations = CursorReputationsObject.create(from: data, id: PrimaryKey.default)(realm)
            reputationsError = nil
            triggerReputationsQuery = false
            
            marked = nil
            markError = nil
            triggerMarkQuery = true
        case .onGetMoreData(let data):
            reputations?.merge(from: data)(realm)
            reputationsError = nil
            triggerReputationsQuery = false
        case .onGetError(let error):
            reputationsError = error.localizedDescription
            triggerReputationsQuery = false
            
        case .onMarkSuccess(let id):
            marked = id
            markError = nil
            triggerMarkQuery = false
        case .onMarkError(let error):
            marked = nil
            markError = error.localizedDescription
            triggerMarkQuery = false
            
        case .onTriggerShowImage(let mediumId):
            imageDetialRoute?.mediumId = mediumId
            imageDetialRoute?.updateVersion()
        case .onTriggerShowUser(let userId):
            userRoute?.userId = userId
            userRoute?.updateVersion()
        case .onTriggerPop:
            popRoute?.updateVersion()
        }
    }
}
