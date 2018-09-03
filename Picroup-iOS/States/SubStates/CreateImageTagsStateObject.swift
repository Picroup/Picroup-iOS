//
//  CreateImageTagsStateObject.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/9/3.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RealmSwift

final class CreateImageTagsStateObject: PrimaryObject {
    let tagStates = List<TagStateObject>()
    @objc dynamic var selectedTagHistory: SelectedTagHistoryObject?
}

extension CreateImageTagsStateObject {
    var selectedTags: [String]? {
        return tagStates.compactMap { $0.isSelected ? $0.tag : nil }
    }
}

extension CreateImageTagsStateObject {
    
    static func createValues(id: String) -> Any {
        return [
            "_id": id,
            "selectedTagHistory": ["_id": id],
        ]
    }
}

extension CreateImageTagsStateObject {
    
    enum Event {
        case resetTagStates
        case onToggleTag(String)
        case onAddTag(String)
    }
}

extension CreateImageTagsStateObject: IsFeedbackStateObject {
    
    func reduce(event: Event, realm: Realm) {
        switch event {
        case .resetTagStates:
            let tags = selectedTagHistory?.getTags().toArray() ?? []
            let tagStates = tags.map { realm.create(TagStateObject.self, value: ["tag": $0]) }
            self.tagStates.removeAll()
            self.tagStates.append(objectsIn: tagStates)
        case .onToggleTag(let tag):
            if let tagState = tagStates.first(where: { $0.tag == tag }) {
                tagState.isSelected = !tagState.isSelected
                if tagState.isSelected { selectedTagHistory?.accept(tag) }
            }
        case .onAddTag(let tag):
            if let tagState = tagStates.first(where: { $0.tag == tag }) {
                tagState.isSelected = true
            } else {
                let newTag = realm.create(TagStateObject.self, value: ["tag": tag])
                newTag.isSelected = true
                tagStates.append(newTag)
            }
            selectedTagHistory?.accept(tag)
        }
    }
}
