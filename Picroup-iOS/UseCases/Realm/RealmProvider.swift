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
        let schemaVersion: UInt64 = 16
        let config = Realm.Configuration(
            schemaVersion: schemaVersion,
            migrationBlock: { migration, oldSchemaVersion in
                if (oldSchemaVersion < schemaVersion) { }
        })
        
        Realm.Configuration.defaultConfiguration = config
    }
}
