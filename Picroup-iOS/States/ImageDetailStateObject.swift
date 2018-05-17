//
//  ImageDetailStateObject.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/16.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift
import RxCocoa
import RxRealm

final class ImageDetailStateObject: PrimaryObject {
    
    @objc dynamic var session: UserSessionObject?

    @objc dynamic var medium: MediumObject?
    @objc dynamic var recommendMedia: CursorMediaObject?
    @objc dynamic var mediumError: String?
    @objc dynamic var triggerMediumQuery: Bool = false
    
    @objc dynamic var starMediumVersion: String?
    @objc dynamic var starMediumError: String?
    @objc dynamic var triggerStarMedium: Bool = false

    @objc dynamic var myStaredMedia: CursorMediaObject?
    
    @objc dynamic var imageDetialRoute: ImageDetialRouteObject?
    @objc dynamic var imageCommetsRoute: ImageCommetsRouteObject?
    @objc dynamic var popRoute: PopRouteObject?
}

extension ImageDetailStateObject {
    var mediumId: String { return _id }
    var mediumQuery: MediumQuery? {
        guard let userId = session?.currentUser?._id else { return nil }
        let next = MediumQuery(userId: userId, mediumId: mediumId, cursor: recommendMedia?.cursor.value)
        return triggerMediumQuery ? next : nil
    }
    var shouldQueryMoreRecommendMedia: Bool {
        return !triggerMediumQuery && hasMoreRecommendMedia
    }
    var hasMoreRecommendMedia: Bool {
        return recommendMedia?.cursor.value != nil
    }
    public var shouldStarMedium: Bool {
        return medium?.stared.value != true && !triggerStarMedium
    }
    public var starMediumQuery: StarMediumMutation? {
        guard let userId = session?.currentUser?._id else { return nil }
        let next = StarMediumMutation(userId: userId, mediumId: mediumId)
        return triggerStarMedium ? next : nil
    }
}

private let myStaredMediaId = "meState.myStaredMedia"
private let recommendMediaId: (String) -> String = { "imageDetailState.\($0).recommendMedia" }

extension ImageDetailStateObject {
    
    static func create(mediumId: String) -> (Realm) throws -> ImageDetailStateObject {
        return { realm in
            let _id = Config.realmDefaultPrimaryKey
            let value: Any = [
                "_id": mediumId,
                "session": ["_id": _id],
                "medium": ["_id": mediumId],
                "recommendMedia": ["_id": recommendMediaId(mediumId)],
                "myStaredMedia": ["_id": myStaredMediaId],
                "imageDetialRoute": ["_id": _id],
                "imageCommetsRoute": ["_id": _id],
                "popRoute": ["_id": _id],
                ]
            return try realm.findOrCreate(ImageDetailStateObject.self, forPrimaryKey: mediumId, value: value)
        }
    }
}

extension ImageDetailStateObject {
    
    enum Event {
        case onTriggerReloadData
        case onTriggerGetMoreData
        case onGetReloadData(MediumQuery.Data.Medium)
        case onGetMoreData(MediumQuery.Data.Medium)
        case onGetError(Error)
        
        case onTriggerStarMedium
        case onStarMediumSuccess(StarMediumMutation.Data.StarMedium)
        case onStarMediumError(Error)
        
        case onTriggerShowImage(String)
        case onTriggerShowComments
        case onTriggerPop
    }
}

extension ImageDetailStateObject.Event {
    
    static func onGetData(isReload: Bool) -> (MediumQuery.Data.Medium) -> ImageDetailStateObject.Event {
        return { isReload ? .onGetReloadData($0) : .onGetMoreData($0) }
    }
}

extension ImageDetailStateObject: IsFeedbackStateObject {
    
    func reduce(event: Event, realm: Realm) {
        switch event {
        case .onTriggerReloadData:
            recommendMedia?.cursor.value = nil
            mediumError = nil
            triggerMediumQuery = true
        case .onTriggerGetMoreData:
            guard shouldQueryMoreRecommendMedia else { return }
            mediumError = nil
            triggerMediumQuery = true
        case .onGetReloadData(let data):
            medium = realm.create(MediumObject.self, value: data.snapshot, update: true)
            let fragment = data.recommendedMedia.fragments.cursorMediaFragment
            recommendMedia = CursorMediaObject.create(from: fragment, id: recommendMediaId(_id))(realm)
            mediumError = nil
            triggerMediumQuery = false
        case .onGetMoreData(let data):
            medium = realm.create(MediumObject.self, value: data.snapshot, update: true)
            let fragment = data.recommendedMedia.fragments.cursorMediaFragment
            recommendMedia?.merge(from: fragment)(realm)
            mediumError = nil
            triggerMediumQuery = false
        case .onGetError(let error):
            mediumError = error.localizedDescription
            triggerMediumQuery = false
        case .onTriggerStarMedium:
            guard shouldStarMedium else { return }
            starMediumVersion = nil
            starMediumError = nil
            triggerStarMedium = true
        case .onStarMediumSuccess(let data):
            medium?.stared.value = true
            medium?.endedAt.value = data.endedAt
            starMediumVersion = UUID().uuidString
            starMediumError = nil
            triggerStarMedium = false
            guard let medium = medium else { return }
            myStaredMedia?.items.insert(medium, at: 0)
        case .onStarMediumError(let error):
            starMediumVersion = nil
            starMediumError = error.localizedDescription
            triggerStarMedium = false
        case .onTriggerShowImage(let mediumId):
            imageDetialRoute?.mediumId = mediumId
            imageDetialRoute?.version = UUID().uuidString
        case .onTriggerShowComments:
            imageCommetsRoute?.mediumId = mediumId
            imageCommetsRoute?.version = UUID().uuidString
        case .onTriggerPop:
            popRoute?.version = UUID().uuidString
        }
    }
}

final class ImageDetailStateStore {
    
    let states: Driver<ImageDetailStateObject>
    private let _state: ImageDetailStateObject
    private let mediumId: String
    
    init(mediumId: String) throws {
        let realm = try Realm()
        let _state = try ImageDetailStateObject.create(mediumId: mediumId)(realm)
        let states = Observable.from(object: _state).asDriver(onErrorDriveWith: .empty())
        
        self.mediumId = mediumId
        self._state = _state
        self.states = states
    }
    
    func on(event: ImageDetailStateObject.Event) {
        Realm.backgroundReduce(ofType: ImageDetailStateObject.self, forPrimaryKey: mediumId, event: event)
    }
    
    func medium() -> Driver<MediumObject> {
        guard let medium = _state.medium else { return .empty() }
        return Observable.from(object: medium).asDriver(onErrorDriveWith: .empty())
    }
    
    func recommendMediaItems() -> Driver<[MediumObject]> {
        guard let items = _state.recommendMedia?.items else { return .empty() }
        return Observable.collection(from: items)
            .asDriver(onErrorDriveWith: .empty())
            .map { $0.toArray() }
    }
    
    func mediumWithRecommendMedia() -> Driver<(MediumObject, [MediumObject])> {
        return Driver.combineLatest(medium(), recommendMediaItems())
    }
}
