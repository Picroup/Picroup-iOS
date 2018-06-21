//
//  Object+Delete.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/6/5.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift

extension Object {
    
    public func delete() {
        realm?.delete(self)
    }
}
