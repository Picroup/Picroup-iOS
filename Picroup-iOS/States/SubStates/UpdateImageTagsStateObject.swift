//
//  UpdateImageTagsStateObject.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/9/3.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RealmSwift

final class UpdateImageTagsStateObject: PrimaryObject {
    let tagStates = List<TagStateObject>()
    @objc dynamic var selectedTagHistory: SelectedTagHistoryObject?
}

extension UpdateImageTagsStateObject {
    
    static func createValues(id: String) -> Any {
        return [
            "_id": id,
            "selectedTagHistory": ["_id": id],
        ]
    }
}

extension UpdateImageTagsStateObject {
    
    enum Event {
        case resetTagStates([String]?)
        case onToggleTag(String)
        case onAddTag(String)
    }
}

extension UpdateImageTagsStateObject: IsFeedbackStateObject {
    
    func reduce(event: Event, realm: Realm) {
        switch event {
        case .resetTagStates(let mediumTags):
            let selectedTags = mediumTags ?? []
            let historyTags = selectedTagHistory?.getTags().toArray() ?? []
            let uncontainedHistoryTags = historyTags.filter { !selectedTags.contains($0) }
            let selectedTagStates = selectedTags.map { realm.create(TagStateObject.self, value: ["tag": $0, "isSelected": true]) }
            let historyTagStates = uncontainedHistoryTags.map { realm.create(TagStateObject.self, value: ["tag": $0, "isSelected": false]) }
            self.tagStates.removeAll()
            self.tagStates.append(objectsIn: selectedTagStates)
            self.tagStates.append(objectsIn: historyTagStates)
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

