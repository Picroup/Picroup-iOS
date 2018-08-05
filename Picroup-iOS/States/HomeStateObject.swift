//
//  HomeStateObject.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/17.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift
import RxSwift
import RxCocoa

final class HomeStateObject: PrimaryObject {
    
    @objc dynamic var version: String?
    
    @objc dynamic var session: UserSessionObject?
    
    @objc dynamic var myInterestedMediaState: CursorMediaStateObject?

    @objc dynamic var needUpdate: NeedUpdateStateObject?

    @objc dynamic var createImageRoute: CreateImageRouteObject?
    @objc dynamic var searchUserRoute: SearchUserRouteObject?
    
    @objc dynamic var imageDetialRoute: ImageDetialRouteObject?
    @objc dynamic var imageCommetsRoute: ImageCommetsRouteObject?
    @objc dynamic var userRoute: UserRouteObject?
}

extension HomeStateObject {
    var myInterestedMediaQuery: UserInterestedMediaQuery? {
        guard let userId = session?.currentUserId else { return nil }
        return myInterestedMediaState?.trigger == true
            ? UserInterestedMediaQuery(userId: userId, cursor: myInterestedMediaState?.cursorMedia?.cursor.value)
            : nil
    }
}

extension HomeStateObject {
    
    static func create() -> (Realm) throws -> HomeStateObject {
        return { realm in
            let _id = PrimaryKey.default
            let value: Any = [
                "_id": _id,
                "session": ["_id": _id],
                "myInterestedMediaState": CursorMediaStateObject.valuesBy(id: PrimaryKey.myInterestedMediaId),
                "needUpdate": ["_id": _id],
                "createImageRoute": ["_id": _id],
                "searchUserRoute": ["_id": _id],
                "imageDetialRoute": ["_id": _id],
                "imageCommetsRoute": ["_id": _id],
                "userRoute": ["_id": _id],
                ]
            let state = try realm.update(HomeStateObject.self, value: value)
            return state
        }
    }
}

extension HomeStateObject {
    
    enum Event {
        
        case myInterestedMediaState(CursorMediaStateObject.Event)
        case onTriggerReloadMyInterestedMediaIfNeeded

        case onTriggerShowImage(String)
        case onTriggerShowComments(String)
        case onTriggerShowUser(String)
        
        case onTriggerCreateImage([MediaItem])
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

final class HomeStateStore {
    
    let states: Driver<HomeStateObject>
    private let _state: HomeStateObject
    
    init() throws {
        let realm = try Realm()
        let _state = try HomeStateObject.create()(realm)
        let states = Observable.from(object: _state).asDriver(onErrorDriveWith: .empty())
        
        self._state = _state
        self.states = states
    }
    
    func on(event: HomeStateObject.Event) {
        let id = PrimaryKey.default
        Realm.backgroundReduce(ofType: HomeStateObject.self, forPrimaryKey: id, event: event)
    }
    
    func myInterestedMediaItems() -> Driver<[MediumObject]> {
        guard let items = _state.myInterestedMediaState?.cursorMedia?.items else { return .empty() }
        return Observable.collection(from: items)
//            .delaySubscription(0.3, scheduler: MainScheduler.instance)
            .asDriver(onErrorDriveWith: .empty())
            .map { $0.toArray() }
    }
}
