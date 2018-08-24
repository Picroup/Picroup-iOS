//
//  CursorMediaObject.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/24.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift
import Apollo

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
            let itemSnapshots = fragment.items.lazy.map { $0.fragments.mediumFragment.rawSnapshot }
            let items = itemSnapshots.map { realm.create(Item.self, value: $0, update: true) }
            self.cursor.value = fragment.cursor
            self.items.append(objectsIn: items)
        }
    }
    
    func mergeSample(from fragment: CursorItemsFragment) -> (Realm) -> Void {
        return { realm in
            let itemSnapshots = fragment.items.lazy
                .filter { item in !self.items.contains(where: { $0._id == item.id}) }
                .map { $0.fragments.mediumFragment.rawSnapshot }
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

