//
//  HotMediaStateObject.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/29.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RealmSwift
import Apollo

class TagMediaQueryStateObject: CursorMediaStateObject {}

extension TagMediaQueryStateObject {
    
    func query(tags: [String]?, queryUserId: GraphQLID?) -> HotMediaByTagsQuery? {
        return trigger == true
            ? HotMediaByTagsQuery(tags: tags, queryUserId: queryUserId)
            : nil
        
    }
}
