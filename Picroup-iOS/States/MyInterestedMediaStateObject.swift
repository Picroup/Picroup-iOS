//
//  MyInterestedMediaStateObject.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/18.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift
import RxSwift
import RxCocoa

final class MyInterestedMediaStateObject: PrimaryObject {
    
    @objc dynamic var session: UserSessionObject?
    
    @objc dynamic var myInterestedMedia: CursorMediaObject?
    @objc dynamic var myInterestedMediaError: String?
    @objc dynamic var triggerMyInterestedMediaQuery: Bool = false
    
    @objc dynamic var imageDetialRoute: ImageDetialRouteObject?
    @objc dynamic var imageCommetsRoute: ImageCommetsRouteObject?
    @objc dynamic var userRoute: UserRouteObject?
}

extension MyInterestedMediaStateObject {
    var myInterestedMediaQuery: UserInterestedMediaQuery? {
        guard let userId = session?.currentUser?._id else { return nil }
        let next = UserInterestedMediaQuery(userId: userId, cursor: myInterestedMedia?.cursor.value)
        return triggerMyInterestedMediaQuery ? next : nil
    }
    var shouldQueryMoreMyInterestedMedia: Bool {
        return !triggerMyInterestedMediaQuery && hasMoreMyInterestedMedia
    }
    var isMyInterestedMediaEmpty: Bool {
        guard let items = myInterestedMedia?.items else { return false }
        return !triggerMyInterestedMediaQuery && myInterestedMediaError == nil && items.isEmpty
    }
    var hasMoreMyInterestedMedia: Bool {
        return myInterestedMedia?.cursor.value != nil
    }
    var isReloading: Bool {
        return myInterestedMedia?.cursor.value == nil && triggerMyInterestedMediaQuery
    }
}

extension MyInterestedMediaStateObject {
    
    static func create() -> (Realm) throws -> MyInterestedMediaStateObject {
        return { realm in
            let _id = PrimaryKey.default
            let value: Any = [
                "_id": _id,
                "session": ["_id": _id],
                "myInterestedMedia": ["_id": PrimaryKey.myInterestedMediaId],
                "imageCommetsRoute": ["_id": _id],
                "imageDetialRoute": ["_id": _id],
                "userRoute": ["_id": _id],
                ]
            return try realm.findOrCreate(MyInterestedMediaStateObject.self, forPrimaryKey: _id, value: value)
        }
    }
}

extension MyInterestedMediaStateObject {
    
    enum Event {
        
        case onTriggerReloadMyInterestedMedia
        case onTriggerGetMoreMyInterestedMedia
        case onGetReloadMyInterestedMedia(CursorMediaFragment)
        case onGetMoreMyInterestedMedia(CursorMediaFragment)
        case onGetMyInterestedMediaError(Error)
        
        case onTriggerShowImage(String)
        case onTriggerShowComments(String)
        case onTriggerShowUser(String)
    }
}

extension MyInterestedMediaStateObject.Event {
    
    static func onGetMyInterestedMedia(isReload: Bool) -> (CursorMediaFragment) -> MyInterestedMediaStateObject.Event {
        return { isReload ? .onGetReloadMyInterestedMedia($0) : .onGetMoreMyInterestedMedia($0) }
    }
}

extension MyInterestedMediaStateObject: IsFeedbackStateObject {
    
    func reduce(event: Event, realm: Realm) {
        switch event {
        case .onTriggerReloadMyInterestedMedia:
            myInterestedMedia?.cursor.value = nil
            myInterestedMediaError = nil
            triggerMyInterestedMediaQuery = true
        case .onTriggerGetMoreMyInterestedMedia:
            guard shouldQueryMoreMyInterestedMedia else { return }
            myInterestedMediaError = nil
            triggerMyInterestedMediaQuery = true
        case .onGetReloadMyInterestedMedia(let data):
            myInterestedMedia = CursorMediaObject.create(from: data, id: PrimaryKey.myInterestedMediaId)(realm)
            myInterestedMediaError = nil
            triggerMyInterestedMediaQuery = false
        case .onGetMoreMyInterestedMedia(let data):
            myInterestedMedia?.merge(from: data)(realm)
            myInterestedMediaError = nil
            triggerMyInterestedMediaQuery = false
        case .onGetMyInterestedMediaError(let error):
            myInterestedMediaError = error.localizedDescription
            triggerMyInterestedMediaQuery = false
            
        case .onTriggerShowImage(let mediumId):
            imageDetialRoute?.mediumId = mediumId
            imageDetialRoute?.version = UUID().uuidString
        case .onTriggerShowComments(let mediumId):
            imageCommetsRoute?.mediumId = mediumId
            imageCommetsRoute?.version = UUID().uuidString
        case .onTriggerShowUser(let userId):
            userRoute?.userId = userId
            userRoute?.version = UUID().uuidString
        }
    }
}


final class MyInterestedMediaStateStore {
    
    let states: Driver<MyInterestedMediaStateObject>
    private let _state: MyInterestedMediaStateObject
    
    init() throws {
        let realm = try Realm()
        let _state = try MyInterestedMediaStateObject.create()(realm)
        let states = Observable.from(object: _state).asDriver(onErrorDriveWith: .empty())
        
        self._state = _state
        self.states = states
    }
    
    func on(event: MyInterestedMediaStateObject.Event) {
        let id = PrimaryKey.default
        Realm.backgroundReduce(ofType: MyInterestedMediaStateObject.self, forPrimaryKey: id, event: event)
    }
    
    func myInterestedMediaItems() -> Driver<[MediumObject]> {
        guard let items = _state.myInterestedMedia?.items else { return .empty() }
        return Observable.collection(from: items)
            .delaySubscription(0.3, scheduler: MainScheduler.instance)
            .asDriver(onErrorDriveWith: .empty())
            .map { $0.toArray() }
    }
}


