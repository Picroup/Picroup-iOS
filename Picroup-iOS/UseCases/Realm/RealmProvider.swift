//
//  RealmProvider.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/6/12.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RealmSwift

struct RealmProvider {
    
    static func setup() {
        let config = Realm.Configuration(
            schemaVersion: 0,
            migrationBlock: { migration, oldSchemaVersion in
                if (oldSchemaVersion < 1) { }
        })
        
        Realm.Configuration.defaultConfiguration = config
    }
}