//
//  PrimaryObject.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/14.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift

class PrimaryObject: Object {

    @objc dynamic var _id: String = ""
    
    override static func primaryKey() -> String? {
        return "_id"
    }
}

extension PrimaryObject {
    
    convenience init(id: String) {
        let primaryKey = type(of: self).primaryKey()!
        self.init(value: [primaryKey: id])
    }
}
