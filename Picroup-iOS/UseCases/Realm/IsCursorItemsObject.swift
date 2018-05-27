//
//  IsCursorItemsObject.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/14.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift
import Apollo

protocol IsCursorFragment: GraphQLFragment {
    associatedtype Item: GraphQLSelectionSet
    
    var cursor: Double? { get }
    var items: [Item] { get }
}

protocol IsCursorItemsObject {
    associatedtype CursorItemsFragment: IsCursorFragment
    associatedtype Item: Object
    
    var cursor: RealmOptional<Double> { get }
    var items: List<Item> { get }
    
    static func create(from fragment: CursorItemsFragment, id: String) -> (Realm) -> Self
    func merge(from fragment: CursorItemsFragment) -> (Realm) -> Void
}

extension IsCursorItemsObject where Self: Object {
    
    static func create(from fragment: CursorItemsFragment, id: String) -> (Realm) -> Self {
        return { realm in
            let value: Snapshot = fragment.snapshot.merging(["_id": id]) { $1 }
            return realm.create(Self.self, value: value, update: true)
        }
    }
    
    func merge(from fragment: CursorItemsFragment) -> (Realm) -> Void {
        return { realm in
            let items = fragment.items.map { realm.create(Item.self, value: $0.snapshot, update: true) }
            self.cursor.value = fragment.cursor
            self.items.append(objectsIn: items)
        }
    }
}
