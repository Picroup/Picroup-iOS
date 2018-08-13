//
//  TagMediaStateObject.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/7/11.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift
import RxCocoa
import RxRealm

final class TagMediaStateObject: PrimaryObject {
    
    @objc dynamic var version: String?
    
    @objc dynamic var session: UserSessionObject?
    
    @objc dynamic var hotMediaState: CursorMediaStateObject?

    @objc dynamic var imageDetialRoute: ImageDetialRouteObject?
}

extension TagMediaStateObject {
    var tag: String {
        return _id
    }
    var hotMediaQuery: HotMediaByTagsQuery? {
        return hotMediaState?.trigger == true
            ? HotMediaByTagsQuery(tags: [tag], queryUserId: session?.currentUserId)
            : nil
    }
}

extension TagMediaStateObject {
    
    static func create(tag: String) -> (Realm) throws -> TagMediaStateObject {
        let hotMediaId = PrimaryKey.hotMediaByTagId(tag)
        return { realm in
            let _id = PrimaryKey.default
            let value: Any = [
                "_id": tag,
                "session": ["_id": _id],
                "hotMediaState": CursorMediaStateObject.valuesBy(id: hotMediaId),
                "imageDetialRoute": ["_id": _id],
                ]
            let result = try realm.update(TagMediaStateObject.self, value: value)
            return result
        }
    }
}


extension TagMediaStateObject {
    
    enum Event {
        case hotMediaState(CursorMediaStateObject.Event)
        case onTriggerShowImage(String)
    }
}

extension TagMediaStateObject: IsFeedbackStateObject {
    
    func reduce(event: Event, realm: Realm) {
        switch event {
        case .hotMediaState(let event):
            hotMediaState?.reduce(event: event, realm: realm)
        case .onTriggerShowImage(let mediumId):
            imageDetialRoute?.mediumId = mediumId
            imageDetialRoute?.version = UUID().uuidString
        }
        version = UUID().uuidString
    }
}

final class TagMediaStateObjectStore {
    
    let tag: String
    let states: Driver<TagMediaStateObject>
    private let _state: TagMediaStateObject
    
    init(tag: String) throws {
        let realm = try Realm()
        let _state = try TagMediaStateObject.create(tag: tag)(realm)
        let states = Observable.from(object: _state).asDriver(onErrorDriveWith: .empty())
        
        self.tag = tag
        self._state = _state
        self.states = states
    }
    
    func on(event: TagMediaStateObject.Event) {
        let id = tag
        Realm.backgroundReduce(ofType: TagMediaStateObject.self, forPrimaryKey: id, event: event)
    }
    
    func hotMediaItems() -> Driver<[MediumObject]> {
        guard let items = _state.hotMediaState?.cursorMedia?.items else { return .empty() }
        return Observable.collection(from: items)
            //            .delaySubscription(0.3, scheduler: MainScheduler.instance)
            .asDriver(onErrorDriveWith: .empty())
            .map { $0.toArray() }
    }
}

