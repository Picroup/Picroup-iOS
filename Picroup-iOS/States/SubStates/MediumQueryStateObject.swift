//
//  MediumQueryStateObject.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/9/4.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RealmSwift

final class MediumQueryStateObject: PrimaryObject {
    
    @objc dynamic var medium: MediumObject?
    @objc dynamic var isMediumDeleted: Bool = false
    
    @objc dynamic var recommendMedia: CursorMediaObject?
    @objc dynamic var error: String?
    @objc dynamic var isReload: Bool = false
    @objc dynamic var trigger: Bool = false
}

extension MediumQueryStateObject: IsCursorItemsStateObject {
    var cursorItemsObject: CursorMediaObject? { return recommendMedia }
}

extension MediumQueryStateObject {
    var mediumId: String { return _id }
    func query(currentUserId: String?) -> MediumQuery? {
        let (userId, withStared) = currentUserId == nil
            ? ("", false)
            : (currentUserId!, true)
        return trigger
            ? MediumQuery(userId: userId, mediumId: mediumId, cursor: recommendMedia?.cursor.value, withStared: withStared, queryUserId: currentUserId)
            : nil
    }
}

extension MediumQueryStateObject {
    
    static func createValues(mediumId: String) -> Any {
        return  [
            "_id": mediumId,
            "medium": ["_id": mediumId],
            "recommendMedia": ["_id": PrimaryKey.recommendMediaId(mediumId)],
        ]
    }
}

extension MediumQueryStateObject {
    
    enum Event {
        case onTriggerReload
        case onTriggerGetMore
        case onGetData(MediumQuery.Data.Medium?)
        case onGetError(Error)
        
        case onDeleteMedium
    }
}

extension MediumQueryStateObject: IsFeedbackStateObject {
    
    func reduce(event: Event, realm: Realm) {
        switch event {
        case .onTriggerReload:
            isReload = true
            recommendMedia?.cursor.value = nil
            error = nil
            trigger = true
        case .onTriggerGetMore:
            guard shouldQueryMore else { return }
            isReload = false
            error = nil
            trigger = true
        case .onGetData(let data):
            switch (isReload, data) {
            case (true, let data?):
                medium = realm.create(MediumObject.self, value: data.rawSnapshot, update: true)
                let fragment = data.recommendedMedia.fragments.cursorMediaFragment
                recommendMedia = CursorMediaObject.create(from: fragment, id: PrimaryKey.recommendMediaId(_id))(realm)
            case (false, let data?):
                medium = realm.create(MediumObject.self, value: data.snapshot, update: true)
                let fragment = data.recommendedMedia.fragments.cursorMediaFragment
                recommendMedia?.merge(from: fragment)(realm)
            case (_, nil):
                medium?.delete()
                isMediumDeleted = true
            }
            error = nil
            trigger = false
        case .onGetError(let error):
            self.error = error.localizedDescription
            trigger = false
        case .onDeleteMedium:
            medium?.delete()
        }
    }
}

