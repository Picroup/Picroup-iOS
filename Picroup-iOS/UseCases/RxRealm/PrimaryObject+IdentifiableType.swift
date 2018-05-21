//
//  PrimaryObject+IdentifiableType.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/21.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift
import RxDataSources

extension PrimaryObject: IdentifiableType {
    
    public var identity: String {
        return _id
    }
}
