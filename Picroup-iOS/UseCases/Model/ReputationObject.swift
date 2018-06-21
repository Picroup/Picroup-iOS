//
//  ReputationObject.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/16.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift
import Apollo

final class ReputationObject: PrimaryObject {
    @objc dynamic var userId: String?
    @objc dynamic var toUserId: String?
    @objc dynamic var mediumId: String?
    @objc dynamic var content: String?
    @objc dynamic var kind: String?
    
    let createdAt = RealmOptional<Double>()
    let viewed = RealmOptional<Bool>()
    let value = RealmOptional<Int>()

    @objc dynamic var user: UserObject?
    @objc dynamic var medium: MediumObject?
}

final class CursorReputationsObject: PrimaryObject {
    
    let cursor = RealmOptional<Double>()
    let items = List<ReputationObject>()
}

extension CursorReputationsObject: IsCursorItemsObject {
    typealias CursorItemsFragment = CursorReputationLinksFragment
    
    static func create(from fragment: CursorItemsFragment, id: String) -> (Realm) -> CursorReputationsObject {
        return { realm in
            let itemSnapshots = fragment.items.map { $0.fragments.reputationFragment.rawSnapshot }
            let value: Snapshot = fragment.snapshot.merging(["_id": id, "items": itemSnapshots]) { $1 }
            return realm.create(CursorReputationsObject.self, value: value, update: true)
        }
    }
    
    func merge(from fragment: CursorItemsFragment) -> (Realm) -> Void {
        return { realm in
            let itemSnapshots = fragment.items.map { $0.fragments.reputationFragment.rawSnapshot }
            let items = itemSnapshots.map { realm.create(Item.self, value: $0, update: true) }
            self.cursor.value = fragment.cursor
            self.items.append(objectsIn: items)
        }
    }
}

extension CursorReputationLinksFragment: IsCursorFragment {}

extension ReputationFragment {
    
    var rawSnapshot: Snapshot {
        return snapshot.merging([
            "kind": kind.rawValue,
            "medium": medium?.fragments.mediumFragment.rawSnapshot
        ]) { $1 }
    }
}
