//
//  RankStateService.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/14.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift
import RxCocoa
import RxRealm

final class RankStateObject: PrimaryObject {
    
    @objc dynamic var session: UserSessionObject?
    
    let tagStates = List<TagStateObject>()
    
    @objc dynamic var hotMedia: CursorMediaObject?
    @objc dynamic var hotMediaError: String?
    @objc dynamic var isReloadHotMedia: Bool = false
    @objc dynamic var triggerHotMediaQuery: Bool = false
    
    @objc dynamic var selectedTagHistory: SelectedTagHistoryObject?
    
    @objc dynamic var loginRoute: LoginRouteObject?
    @objc dynamic var imageDetialRoute: ImageDetialRouteObject?
}

extension RankStateObject {
    var hotMediaQuery: HotMediaByTagQuery? {
        return triggerHotMediaQuery ? HotMediaByTagQuery(tag: selectedTag) : nil
    }
    private var selectedTag: String? {
        return tagStates.first(where: { $0.isSelected == true })?.tag
    }
    var shouldQueryMoreHotMedia: Bool {
        return !triggerHotMediaQuery
    }
}

extension RankStateObject {
    
    static func create() -> (Realm) throws -> RankStateObject {
        let hotMediaId = PrimaryKey.hotMediaId
        return { realm in
            let _id = PrimaryKey.default
            let value: Any = [
                "_id": _id,
                "session": ["_id": _id],
//                "rankMedia": ["_id": rankMediaId],
                "hotMedia": ["_id": hotMediaId],
                "selectedTagHistory": ["_id": "viewTagHistory"],
                "loginRoute": ["_id": _id],
                "imageDetialRoute": ["_id": _id],
                ]
            let result = try realm.update(RankStateObject.self, value: value)
            try realm.write {
                result.resetTagStates(realm: realm)
            }
            return result
        }
    }
}

extension RankStateObject {
    
    fileprivate func resetTagStates(realm: Realm) {
        let tags = selectedTagHistory?.getTags().toArray() ?? []
        let tagStates = tags.map { realm.create(TagStateObject.self, value: ["tag": $0]) }
        tagStates.first?.isSelected = true
        self.tagStates.removeAll()
        self.tagStates.append(objectsIn: tagStates)
    }
}

extension RankStateObject {
    
    enum Event {
        case onTriggerReload
        case onTriggerGetMore
//        case onGetReloadData(CursorMediaFragment)
//        case onGetMoreData(CursorMediaFragment)
        case onGetData(CursorMediaFragment)
        case onGetError(Error)
        case onToggleTag(String)
        case onTriggerLogin
        case onTriggerShowImage(String)
    }
}

extension RankStateObject: IsFeedbackStateObject {
    
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
                hotMedia = CursorMediaObject.create(from: data, id: PrimaryKey.hotMediaId)(realm)
                isReloadHotMedia = false
            } else {
                hotMedia?.merge(from: data)(realm)
            }
            hotMediaError = nil
            triggerHotMediaQuery = false
        case .onGetError(let error):
            hotMediaError = error.localizedDescription
            triggerHotMediaQuery = false
        case .onToggleTag(let tag):
            tagStates.forEach { tagState in
                if tagState.tag == tag {
                    tagState.isSelected = !tagState.isSelected
                    if tagState.isSelected { selectedTagHistory?.accept(tag) }
                } else {
                    tagState.isSelected = false
                }
            }
            isReloadHotMedia = true
            hotMediaError = nil
            triggerHotMediaQuery = true
        case .onTriggerLogin:
            loginRoute?.version = UUID().uuidString
        case .onTriggerShowImage(let mediumId):
            imageDetialRoute?.mediumId = mediumId
            imageDetialRoute?.version = UUID().uuidString
        }
    }
}

final class RankStateStore {
    
    let states: Driver<RankStateObject>
    private let _state: RankStateObject
    
    init() throws {
        let realm = try Realm()
        let _state = try RankStateObject.create()(realm)
        let states = Observable.from(object: _state).asDriver(onErrorDriveWith: .empty())
        
        self._state = _state
        self.states = states
    }
    
    func on(event: RankStateObject.Event) {
        let id = PrimaryKey.default
        Realm.backgroundReduce(ofType: RankStateObject.self, forPrimaryKey: id, event: event)
    }
    
//    func rankMediaItems() -> Driver<[MediumObject]> {
//        guard let items = _state.rankMedia?.items else { return .empty() }
//        return Observable.collection(from: items)
////            .delaySubscription(0.3, scheduler: MainScheduler.instance)
//            .asDriver(onErrorDriveWith: .empty())
//            .map { $0.toArray() }
//    }
    
    func hotMediaItems() -> Driver<[MediumObject]> {
        guard let items = _state.hotMedia?.items else { return .empty() }
        return Observable.collection(from: items)
            //            .delaySubscription(0.3, scheduler: MainScheduler.instance)
            .asDriver(onErrorDriveWith: .empty())
            .map { $0.toArray() }
    }
    
    func tagStates() -> Driver<[TagStateObject]> {
        return Observable.collection(from: _state.tagStates)
            .asDriver(onErrorDriveWith: .empty())
            .map { $0.toArray() }
    }
}

