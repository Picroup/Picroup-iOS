//
//  Realm+findOrCreate.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/14.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift

extension Realm {
    
    public func findOrCreate<Element, KeyType>(_ type: Element.Type, forPrimaryKey key: KeyType, value: Any) throws -> Element where Element : Object {
        if let element = object(ofType: type, forPrimaryKey: key) {
            return element
        }
        var element: Element?
        try write {
            element = create(type, value: value, update: true)
        }
        return element!
    }
}
