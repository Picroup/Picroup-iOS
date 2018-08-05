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
    
    @objc dynamic var version: String?

    @objc dynamic var session: UserSessionObject?
    
    let tagStates = List<TagStateObject>()
    
    @objc dynamic var hotMediaState: CursorMediaStateObject?

    @objc dynamic var selectedTagHistory: SelectedTagHistoryObject?
    
    @objc dynamic var loginRoute: LoginRouteObject?
    @objc dynamic var imageDetialRoute: ImageDetialRouteObject?
}

extension RankStateObject {
    var hotMediaQuery: HotMediaByTagsQuery? {
        return hotMediaState?.trigger == true
            ? HotMediaByTagsQuery(tags: selectedTags, queryUserId: session?.currentUserId)
            : nil
    }
    private var selectedTags: [String]? {
        return tagStates.first(where: { $0.isSelected })
            .map { [$0.tag] }
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
                "hotMediaState": CursorMediaStateObject.valuesBy(id: hotMediaId),
                "selectedTagHistory": ["_id": PrimaryKey.viewTagHistory],
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
        case hotMediaState(CursorMediaStateObject.Event)
        case onToggleTag(String)
        case onTriggerLogin
        case onTriggerShowImage(String)
    }
}

extension RankStateObject: IsFeedbackStateObject {
    
    func reduce(event: Event, realm: Realm) {
        switch event {
        case .hotMediaState(let event):
            hotMediaState?.reduce(event: event, realm: realm)
            if case .onGetData = event {
                hotMediaState?.cursorMedia?.cursor.value = 0
            }
        case .onToggleTag(let tag):
            tagStates.forEach { tagState in
                if tagState.tag == tag {
                    tagState.isSelected = !tagState.isSelected
                    if tagState.isSelected { selectedTagHistory?.accept(tag) }
                } else {
                    tagState.isSelected = false
                }
            }
            hotMediaState?.reduce(event: .onTriggerReload, realm: realm)
        case .onTriggerLogin:
            loginRoute?.version = UUID().uuidString
        case .onTriggerShowImage(let mediumId):
            imageDetialRoute?.mediumId = mediumId
            imageDetialRoute?.version = UUID().uuidString
        }
        version = UUID().uuidString
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
    
    func hotMediaItems() -> Driver<[MediumObject]> {
        guard let items = _state.hotMediaState?.cursorMedia?.items else { return .empty() }
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

