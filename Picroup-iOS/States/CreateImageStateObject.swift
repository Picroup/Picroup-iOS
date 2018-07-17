//
//  CreateImageStateObject.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/17.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift
import RxCocoa
import RxRealm
import RxAlamofire
import YPImagePicker

public final class RxProgressObject: Object {
    @objc public dynamic var bytesWritten: Int = 0
    @objc public dynamic var totalBytes: Int = 0
}

extension RxProgressObject {
    public var completed: Float {
        if totalBytes > 0 {
            return Float(bytesWritten) / Float(totalBytes)
        }
        else {
            return 0
        }
    }
}

final class SaveMediumStateObject: PrimaryObject {
    
    @objc dynamic var progress: RxProgressObject?
    @objc dynamic var savedMedium: MediumObject?
    @objc dynamic var savedError: String?
}

final class TagStateObject: Object {
    
    @objc dynamic var tag: String = ""
    @objc dynamic var isSelected: Bool = false
}

final class MediaItemObject: PrimaryObject {
    @objc dynamic var kind: String?
    @objc dynamic var imageKey: String?
    @objc dynamic var thumbnailImageKey: String?
    @objc dynamic var videoFilePath: String?
    
    var videoFileURL: URL? {
        get { return videoFilePath.flatMap(URL.init(string: )) }
        set { videoFilePath = newValue?.absoluteString }
    }
    
    static func create(mediaItem: MediaItem) -> (Realm) -> MediaItemObject {
        return { realm in
            
            let value: Any = {
                switch mediaItem {
                case .image(let imageKey):
                    return [
                        "_id": mediaItem.id,
                        "kind": MediumKind.image.rawValue,
                        "imageKey": imageKey,
                    ]
                case .video(let thumbnailImageKey, let videoFileURL):
                    return [
                        "_id": mediaItem.id,
                        "kind": MediumKind.video.rawValue,
                        "thumbnailImageKey": thumbnailImageKey,
                        "videoFileURL": videoFileURL,
                    ]
                }
            }()

            return realm.create(MediaItemObject.self, value: value)
        }
    }
    
    var mediaItem: MediaItem {
        switch (kind, imageKey, thumbnailImageKey, videoFileURL) {
        case (MediumKind.image.rawValue?, let imageKey?, _, _):
            return .image(imageKey)
        case (MediumKind.video.rawValue?, _, let thumbnailImageKey?, let videoFileURL?):
            return .video(thumbnailImageKey: thumbnailImageKey, videoFileURL: videoFileURL)
        default:
            fatalError("CreateMediaQueryObject can't convert to MediaItem: \(self)")
        }
    }
}

extension MediaItem {
    var id: String {
        switch self {
        case .image(let imageKey):
            return imageKey
        case .video(let thumbnailImageKey, _):
            return thumbnailImageKey
        }
    }
}

final class CreateImageStateObject: PrimaryObject {
    typealias Query = (userId: String, mediaItems: [MediaItem], tags: [String]?)

    @objc dynamic var session: UserSessionObject?
    
    let mediaItemObjects = List<MediaItemObject>()
    let tagStates = List<TagStateObject>()
    let saveMediumStates = List<SaveMediumStateObject>()
    @objc dynamic var finished: Int = 0
    @objc dynamic var triggerSaveMediumQuery: Bool = false
    
    @objc dynamic var selectedTagHistory: SelectedTagHistoryObject?
    
    @objc dynamic var needUpdate: NeedUpdateStateObject?

    @objc dynamic var popRoute: PopRouteObject?
    
    @objc dynamic var snackbar: SnackbarObject?
}

extension CreateImageStateObject {
    var saveQuery: Query? {
        guard let userId = session?.currentUser?._id else { return nil }
        return triggerSaveMediumQuery ? (userId: userId, mediaItems: mediaItemObjects.map { $0.mediaItem }, tags: selectedTags) : nil
    }
    private var selectedTags: [String]? {
        return tagStates.compactMap { $0.isSelected ? $0.tag : nil }
    }
    var shouldSaveMedium: Bool {
        return !triggerSaveMediumQuery
    }
    var allFinished: Bool { return finished == mediaItemObjects.count }
    var completed: Float {
        let count = saveMediumStates.count
        let allProgress = saveMediumStates.reduce(0) { $0 + ($1.progress?.completed ?? 0)
        }
        if count > 0 {
            return Float(allProgress) / Float(count)
        }
        else {
            return 0
        }
    }
}

extension CreateImageStateObject {
    
    static func create(mediaItems: [MediaItem]) -> (Realm) throws -> CreateImageStateObject {
        return { realm in
            let _id = PrimaryKey.default
            let value: Any = [
                "_id": _id,
                "session": ["_id": _id],
                "mediaItemObjects": mediaItems.map { ["_id": $0.id] },
                "tags": [],
                "saveMediumStates": mediaItems.map { ["_id": $0.id, "progress": [:]] },
                "finished": 0,
                "triggerSaveMediumQuery": false,
                "selectedTagHistory": ["_id": _id],
                "needUpdate": ["_id": _id],
                "popRoute": ["_id": _id],
                "snackbar": ["_id": _id],
                ]
            let result = try realm.update(CreateImageStateObject.self, value: value)
            try realm.write {
                result.resetTagStates(realm: realm)
            }
            return result
        }
    }
}

extension CreateImageStateObject {
    
    fileprivate func resetTagStates(realm: Realm) {
        let tags = selectedTagHistory?.getTags().toArray() ?? []
        let tagStates = tags.map { realm.create(TagStateObject.self, value: ["tag": $0]) }
        self.tagStates.removeAll()
        self.tagStates.append(objectsIn: tagStates)
    }
}

extension CreateImageStateObject {
    enum Event {
        case onTriggerSaveMedium
        case onProgress(RxProgress, Int)
        case onSavedMediumSuccess(MediumFragment, Int)
        case onSavedMediumError(Error, Int)
        case onToggleTag(String)
        case onAddTag(String)
//        case triggerCancel
    }
}

extension CreateImageStateObject: IsFeedbackStateObject {
    
    func reduce(event: Event, realm: Realm) {
        switch event {
        case .onTriggerSaveMedium:
            guard shouldSaveMedium else { return }
            triggerSaveMediumQuery = true
        case .onProgress(let progress, let index):
            saveMediumStates[index].progress?.bytesWritten = Int(progress.bytesWritten)
            saveMediumStates[index].progress?.totalBytes = Int(progress.totalBytes)
            triggerSaveMediumQuery = true // trigger state update
        case .onSavedMediumSuccess(let medium, let index):
            let mediumObject = realm.create(MediumObject.self, value: medium.rawSnapshot, update: true)
            saveMediumStates[index].savedMedium = mediumObject
            finished += 1
            if allFinished {
                triggerSaveMediumQuery = false
                needUpdate?.myInterestedMedia = true
                needUpdate?.myMedia = true
                let failState = saveMediumStates.first(where: { $0.savedError != nil })
                let allSuccess = failState == nil
                if allSuccess {
                    snackbar?.message = "已分享"
                    snackbar?.version = UUID().uuidString
                    popRoute?.version = UUID().uuidString
                }
            }
        case .onSavedMediumError(let error, let index):
            saveMediumStates[index].savedMedium = nil
            saveMediumStates[index].savedError = error.localizedDescription
            finished += 1
            if allFinished {
                triggerSaveMediumQuery = false
                needUpdate?.myInterestedMedia = true
                needUpdate?.myMedia = true
            }
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

final class CreateImageStateStore {
    
    let states: Driver<CreateImageStateObject>
    private let _state: CreateImageStateObject
    
    init(mediaItems: [MediaItem]) throws {
        let realm = try Realm()
        let _state = try CreateImageStateObject.create(mediaItems: mediaItems)(realm)
        let states = Observable.from(object: _state).asDriver(onErrorDriveWith: .empty())
        
        self._state = _state
        self.states = states
    }
    
    func on(event: CreateImageStateObject.Event) {
        Realm.backgroundReduce(ofType: CreateImageStateObject.self, forPrimaryKey: PrimaryKey.default, event: event)
    }
    
    func saveMediumStates() -> Driver<[SaveMediumStateObject]> {
        return Observable.collection(from: _state.saveMediumStates)
            .asDriver(onErrorDriveWith: .empty())
            .map { $0.toArray() }
    }
    
    func tagStates() -> Driver<[TagStateObject]> {
        return Observable.collection(from: _state.tagStates)
            .asDriver(onErrorDriveWith: .empty())
            .map { $0.toArray() }
    }
}
