//
//  MediumObject.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/14.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift
import Apollo

final class MediumObject: PrimaryObject {
    
    @objc dynamic var userId: String?
    @objc dynamic var detail: MediumDetailObject?
    @objc dynamic var minioId: String?
    @objc dynamic var kind: String?
    let createdAt = RealmOptional<Double>()
    let endedAt = RealmOptional<Double>()
    let stared = RealmOptional<Bool>()
    let commentsCount = RealmOptional<Int>()
    let tags = List<String>()

    @objc dynamic var user: UserObject?
}

final class MediumDetailObject: Object {
    let width = RealmOptional<Double>()
    let aspectRatio = RealmOptional<Double>()
}

final class CursorMediaObject: PrimaryObject {
    
    let cursor = RealmOptional<Double>()
    let items = List<MediumObject>()
}

extension CursorMediaObject: IsCursorItemsObject {
    typealias CursorItemsFragment = CursorMediaFragment
    
    static func create(from fragment: CursorItemsFragment, id: String) -> (Realm) -> CursorMediaObject {
        return { realm in
            let itemSnapshots = fragment.items.map { $0.fragments.mediumFragment.rawSnapshot }
            let value: Snapshot = fragment.snapshot.merging(["_id": id, "items": itemSnapshots]) { $1 }
            return realm.create(CursorMediaObject.self, value: value, update: true)
        }
    }
    
    func merge(from fragment: CursorItemsFragment) -> (Realm) -> Void {
        return { realm in
            let itemSnapshots = fragment.items.map { $0.fragments.mediumFragment.rawSnapshot }
            let items = itemSnapshots.map { realm.create(Item.self, value: $0, update: true) }
            self.cursor.value = fragment.cursor
            self.items.append(objectsIn: items)
        }
    }
}

extension CursorMediaFragment: IsCursorFragment {}

extension MediumFragment {
    
    var rawSnapshot: Snapshot {
        return snapshot.merging(["kind": kind.rawValue]) { $1 }
    }
}

extension MediumQuery.Data.Medium {
    
    var rawSnapshot: Snapshot {
        return snapshot.merging(["kind": kind.rawValue]) { $1 }
    }
}

//extension CursorMediaObject {
//    
//    func mergeUnique(from data: CursorMediaFragment) -> (Realm) -> Void {
//        return { realm in
//            let items: [MediumObject] = data.items.compactMap { mediaFragment in
//                if self.items.contains(where: { $0._id == mediaFragment.id }) { return nil }
//                return realm.create(MediumObject.self, value: mediaFragment.snapshot, update: true)
//            }
//            self.cursor.value = data.cursor
//            self.items.append(objectsIn: items)
//        }
//    }
//}

