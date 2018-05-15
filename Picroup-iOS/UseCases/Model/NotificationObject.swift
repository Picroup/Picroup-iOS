//
//  NotificationObject.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/14.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift
import Apollo

final class NotificationObject: PrimaryObject {
    @objc dynamic var userId: String?
    @objc dynamic var toUserId: String?
    @objc dynamic var mediumId: String?
    @objc dynamic var content: String?
    @objc dynamic var kind: String?

    let createdAt = RealmOptional<Double>()
    let endedAt = RealmOptional<Double>()
    let viewed = RealmOptional<Bool>()
    
    @objc dynamic var user: UserObject?
    @objc dynamic var medium: MediumObject?
}

final class CursorNotifications: PrimaryObject {
    
    let cursor = RealmOptional<Double>()
    let items = List<NotificationObject>()
}

extension CursorNotifications: IsCursorItemsObject {
    typealias CursorItemsFragment = CursorNotoficationsFragment
    
    static func create(from fragment: CursorItemsFragment, id: String) -> (Realm) -> CursorNotifications {
        return { realm in
            let itemSnapshots = fragment.items.map { $0.fragments.notificationFragment.rawSnapshot }
            let value: Snapshot = fragment.snapshot.merging(["_id": id, "items": itemSnapshots]) { $1 }
            return realm.create(CursorNotifications.self, value: value, update: true)
        }
    }
    
    func merge(from fragment: CursorItemsFragment) -> (Realm) -> Void {
        return { realm in
            let itemSnapshots = fragment.items.map { $0.fragments.notificationFragment.rawSnapshot }
            let items = itemSnapshots.map { realm.create(Item.self, value: $0, update: true) }
            self.cursor.value = fragment.cursor
            self.items.append(objectsIn: items)
        }
    }
}

extension CursorNotoficationsFragment: IsCursorFragment {}

extension NotificationFragment {
    
    var rawSnapshot: Snapshot {
        return snapshot.merging(["kind": kind.rawValue]) { $1 }
    }
}
