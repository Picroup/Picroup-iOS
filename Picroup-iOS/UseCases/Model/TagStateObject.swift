//
//  TagStateObject.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/23.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift

final class TagStateObject: Object {
    
    @objc dynamic var tag: String = ""
    @objc dynamic var isSelected: Bool = false
}
