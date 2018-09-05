//
//  HotMediaTagsStateObject.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/29.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RealmSwift

final class HotMediaTagsStateObject: PrimaryObject {
    let tagStates = List<TagStateObject>()
    @objc dynamic var selectedTagHistory: SelectedTagHistoryObject?
}

extension HotMediaTagsStateObject {
    var selectedTags: [String]? {
        return tagStates.first(where: { $0.isSelected })
            .map { [$0.tag] }
    }
}

extension HotMediaTagsStateObject {
    
    static func createValues() -> Any {
        return [
            "_id": PrimaryKey.default,
            "selectedTagHistory": ["_id": PrimaryKey.viewTagHistory],
        ]
    }
}

extension HotMediaTagsStateObject {
    
    enum Event {
        case resetTagStates
        case onToggleTag(String)
    }
}

extension HotMediaTagsStateObject: IsFeedbackStateObject {
    
    func reduce(event: Event, realm: Realm) {
        switch event {
        case .resetTagStates:
            let tags = selectedTagHistory?.getTags().toArray() ?? []
            let tagStates = tags.map { realm.create(TagStateObject.self, value: ["tag": $0]) }
            tagStates.first?.isSelected = true
            self.tagStates.removeAll()
            self.tagStates.append(objectsIn: tagStates)
        case .onToggleTag(let tag):
            tagStates.forEach { tagState in
                if tagState.tag == tag {
                    tagState.isSelected = !tagState.isSelected
                    if tagState.isSelected { selectedTagHistory?.accept(tag) }
                } else {
                    tagState.isSelected = false
                }
            }
        }
    }
}
