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
    let createdAt = RealmOptional<Double>()
    let endedAt = RealmOptional<Double>()
    let stared = RealmOptional<Bool>()
    let commentsCount = RealmOptional<Int>()
    
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
}

extension CursorMediaFragment: IsCursorFragment {}

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

