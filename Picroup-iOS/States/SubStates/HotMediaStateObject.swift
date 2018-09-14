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

final class TagMediaQueryStateObject: CursorMediaQueryStateObject {}

extension TagMediaQueryStateObject {
    
    func query(tags: [String]?, queryUserId: GraphQLID?) -> HotMediaByTagsQuery? {
        let (userId, withStared) = createWithStarInfo(currentUserId: queryUserId)
        return trigger == true
            ? HotMediaByTagsQuery(tags: tags, userId: userId, withStared: withStared)
            : nil
        
    }
}
