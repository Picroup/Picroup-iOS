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
    
    @objc dynamic var session: UserSessionObject?
    
    @objc dynamic var hotMedia: CursorMediaObject?
    @objc dynamic var hotMediaError: String?
    @objc dynamic var isReloadHotMedia: Bool = false
    @objc dynamic var triggerHotMediaQuery: Bool = false
    
    @objc dynamic var imageDetialRoute: ImageDetialRouteObject?
}

extension TagMediaStateObject {
    var tag: String {
        return _id
    }
    var hotMediaQuery: HotMediaByTagsQuery? {
        return triggerHotMediaQuery ? HotMediaByTagsQuery(tags: [tag]) : nil
    }
    var shouldQueryMoreHotMedia: Bool {
        return !triggerHotMediaQuery
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
                "hotMedia": ["_id": hotMediaId],
                "imageDetialRoute": ["_id": _id],
                ]
            let result = try realm.update(TagMediaStateObject.self, value: value)
            return result
        }
    }
}


extension TagMediaStateObject {
    
    enum Event {
        case onTriggerReload
        case onTriggerGetMore
        case onGetData(CursorMediaFragment)
        case onGetError(Error)
        case onTriggerShowImage(String)
    }
}

extension TagMediaStateObject: IsFeedbackStateObject {
    
    func reduce(event: Event, realm: Realm) {
        switch event {
        case .onTriggerReload:
            isReloadHotMedia = true
            hotMediaError = nil
            triggerHotMediaQuery = true
        case .onTriggerGetMore:
            guard shouldQueryMoreHotMedia else { return }
            isReloadHotMedia = false
            hotMediaError = nil
            triggerHotMediaQuery = true
        case .onGetData(let data):
            if isReloadHotMedia {
                let hotMediaId = PrimaryKey.hotMediaByTagId(tag)
                hotMedia = CursorMediaObject.create(from: data, id: hotMediaId)(realm)
                isReloadHotMedia = false
            } else {
                hotMedia?.merge(from: data)(realm)
            }
            hotMediaError = nil
            triggerHotMediaQuery = false
        case .onGetError(let error):
            hotMediaError = error.localizedDescription
            triggerHotMediaQuery = false
        case .onTriggerShowImage(let mediumId):
            imageDetialRoute?.mediumId = mediumId
            imageDetialRoute?.version = UUID().uuidString
        }
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
        guard let items = _state.hotMedia?.items else { return .empty() }
        return Observable.collection(from: items)
            //            .delaySubscription(0.3, scheduler: MainScheduler.instance)
            .asDriver(onErrorDriveWith: .empty())
            .map { $0.toArray() }
    }
}

