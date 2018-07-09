//
//  TagObject.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/7/9.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift

final class SelectedTagHistoryObject: PrimaryObject {
    let tags = List<String>()
}

extension SelectedTagHistoryObject {
    
    func getTags() -> List<String> {
        if tags.isEmpty {
            tags.append(objectsIn: [
            "搞笑",
            "美女",
            "动物",
            "帅哥",
            "摄影",
            "风景",
            "人文",
            ])
        }
        return tags
    }
    
    func accept(_ tag: String) {
        if let index = tags.index(of: tag) {
            tags.remove(at: index)
        }
        tags.insert(tag, at: 0)
        while tags.count > 10 {
            tags.removeLast()
        }
    }
}
