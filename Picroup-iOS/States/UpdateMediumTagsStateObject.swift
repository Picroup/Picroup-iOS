//
//  UpdateMediumTagsStateObject.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/7/11.
//  Copyright © 2018年 luojie. All rights reserved.
//


import Foundation
import RealmSwift
import RxSwift
import RxCocoa
import RxRealm
import RxAlamofire

final class UpdateMediumTagsStateObject: PrimaryObject {
    
    @objc dynamic var session: UserSessionObject?
    @objc dynamic var medium: MediumObject?

    let tagStates = List<TagStateObject>()
    
    @objc dynamic var selectedTagHistory: SelectedTagHistoryObject?
    
    @objc dynamic var addTag: String?
    @objc dynamic var addTagError: String?
    @objc dynamic var triggerAddTagQuery: Bool = false
    
    @objc dynamic var removeTag: String?
    @objc dynamic var removeTagError: String?
    @objc dynamic var triggerRemoveTagQuery: Bool = false

    @objc dynamic var snackbar: SnackbarObject?
}

extension UpdateMediumTagsStateObject {
    var mediumId: String { return _id }
    var addTagQuery: MediumAddTagQuery? {
        guard let tag = addTag, let byUserId = session?.currentUser?._id else { return nil }
        return triggerAddTagQuery ? MediumAddTagQuery(mediumId: mediumId, tag: tag, byUserId: byUserId) : nil
    }
    var removeTagQuery: MediumRemoveTagQuery? {
        guard let tag = removeTag, let byUserId = session?.currentUser?._id else { return nil }
        return triggerRemoveTagQuery ? MediumRemoveTagQuery(mediumId: mediumId, tag: tag, byUserId: byUserId) : nil
    }
}

extension UpdateMediumTagsStateObject {
    
    static func create(mediumId: String) -> (Realm) throws -> UpdateMediumTagsStateObject {
        return { realm in
            let _id = PrimaryKey.default
            let value: Any = [
                "_id": mediumId,
                "session": ["_id": _id],
                "medium": ["_id": mediumId],
                "selectedTagHistory": ["_id": _id],
                "snackbar": ["_id": _id],
                ]
            let result = try realm.update(UpdateMediumTagsStateObject.self, value: value)
            try realm.write {
                result.resetTagStates(realm: realm)
            }
            return result
        }
    }
}

extension UpdateMediumTagsStateObject {
    
    fileprivate func resetTagStates(realm: Realm) {
        let selectedTags = medium?.tags.toArray() ?? []
        let historyTags = selectedTagHistory?.getTags().toArray() ?? []
        let uncontainedHistoryTags = historyTags.filter { !selectedTags.contains($0) }
        let selectedTagStates = selectedTags.map { realm.create(TagStateObject.self, value: ["tag": $0, "isSelected": true]) }
        let historyTagStates = uncontainedHistoryTags.map { realm.create(TagStateObject.self, value: ["tag": $0, "isSelected": false]) }
        self.tagStates.removeAll()
        self.tagStates.append(objectsIn: selectedTagStates)
        self.tagStates.append(objectsIn: historyTagStates)
    }
}

extension UpdateMediumTagsStateObject {
    enum Event {
        case onToggleTag(String)
        case onAddTag(String)
        case onAddTagSuccess(MediumFragment)
        case onAddTagError(Error, String)
        case onRemoveTagSuccess(MediumFragment)
        case onRemoveTagError(Error, String)
    }
}

extension UpdateMediumTagsStateObject: IsFeedbackStateObject {
    
    func reduce(event: Event, realm: Realm) {
        switch event {
        case .onToggleTag(let tag):
            if let tagState = tagStates.first(where: { $0.tag == tag }) {
                tagState.isSelected = !tagState.isSelected
                triggerSyncTagState(tagState)
                if tagState.isSelected { selectedTagHistory?.accept(tag) }
            }
        case .onAddTag(let tag):
            if let tagState = tagStates.first(where: { $0.tag == tag }), !tagState.isSelected {
                tagState.isSelected = true
                triggerSyncTagState(tagState)
            } else {
                let newTag = realm.create(TagStateObject.self, value: ["tag": tag])
                newTag.isSelected = true
                triggerSyncTagState(newTag)
                tagStates.append(newTag)
            }
            selectedTagHistory?.accept(tag)
        case .onAddTagSuccess(let data):
            medium = realm.create(MediumObject.self, value: data.rawSnapshot, update: true)
            addTagError = nil
            triggerAddTagQuery = false
        case .onAddTagError(let error, let tag):
            tagStates.first(where: { $0.tag == tag })?.isSelected = false
            addTagError = error.localizedDescription
            triggerAddTagQuery = false
        case .onRemoveTagSuccess(let data):
            medium = realm.create(MediumObject.self, value: data.rawSnapshot, update: true)
            removeTagError = nil
            triggerRemoveTagQuery = false
        case .onRemoveTagError(let error, let tag):
            tagStates.first(where: { $0.tag == tag })?.isSelected = true
            removeTagError = error.localizedDescription
            triggerRemoveTagQuery = false
        }
    }
    
    func triggerSyncTagState(_ tagState: TagStateObject) {
        if tagState.isSelected {
            addTag = tagState.tag
            addTagError = nil
            triggerAddTagQuery = true
        } else {
            removeTag = tagState.tag
            removeTagError = nil
            triggerRemoveTagQuery = true
        }
    }
}

final class UpdateMediumTagsStateStore {
    
    let mediumId: String
    let states: Driver<UpdateMediumTagsStateObject>
    private let _state: UpdateMediumTagsStateObject
    
    init(mediumId: String) throws {
        let realm = try Realm()
        let _state = try UpdateMediumTagsStateObject.create(mediumId: mediumId)(realm)
        let states = Observable.from(object: _state).asDriver(onErrorDriveWith: .empty())
        
        self.mediumId = mediumId
        self._state = _state
        self.states = states
    }
    
    func on(event: UpdateMediumTagsStateObject.Event) {
        let id = mediumId
        Realm.backgroundReduce(ofType: UpdateMediumTagsStateObject.self, forPrimaryKey: id, event: event)
    }
    
    func tagStates() -> Driver<[TagStateObject]> {
        return Observable.collection(from: _state.tagStates)
            .asDriver(onErrorDriveWith: .empty())
            .map { $0.toArray() }
    }
}
