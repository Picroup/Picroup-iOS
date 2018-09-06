//
//  SaveImagesQueryStateObject.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/9/3.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RealmSwift
import RxAlamofire

final class SaveImagesQueryStateObject: PrimaryObject {
    typealias Query = (userId: String, mediaItems: [MediumItem], tags: [String]?)
    
    let mediaItemObjects = List<MediaItemObject>()
    let saveMediumStates = List<SaveMediumStateObject>()
    @objc dynamic var finished: Int = 0
    
    @objc dynamic var success: String?
    @objc dynamic var error: String?
    
    @objc dynamic var trigger: Bool = false
}

extension SaveImagesQueryStateObject {
    
    func query(userId: String?, tags: [String]?) -> Query? {
        guard let userId = userId else { return nil }
        return trigger
            ? (userId: userId, mediaItems: mediaItemObjects.map { $0.mediaItem }, tags: tags)
            : nil
    }
    var shouldQuery: Bool {
        return !trigger
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

extension SaveImagesQueryStateObject {
    
    static func createValues(id: String, mediaItems: [MediumItem]) -> Any {
        return [
            "_id": id,
            "mediaItemObjects": mediaItems.map { ["_id": $0.id] },
            "saveMediumStates": mediaItems.map { ["_id": $0.id, "progress": [:]] },
            "finished": 0,
            "trigger": false,
            "success": nil,
            "error": nil,
        ]
    }
}

extension SaveImagesQueryStateObject {
    enum Event {
        case onTrigger
        case onProgress(RxProgress, Int)
        case onSuccess(MediumFragment, Int)
        case onError(Error, Int)
    }
}

extension SaveImagesQueryStateObject: IsFeedbackStateObject {
    
    func reduce(event: Event, realm: Realm) {
        switch event {
        case .onTrigger:
            guard shouldQuery else { return }
            trigger = true
        case .onProgress(let progress, let index):
            saveMediumStates[index].progress?.bytesWritten = Int(progress.bytesWritten)
            saveMediumStates[index].progress?.totalBytes = Int(progress.totalBytes)
        case .onSuccess(let medium, let index):
            let mediumObject = realm.create(MediumObject.self, value: medium.rawSnapshot, update: true)
            saveMediumStates[index].savedMedium = mediumObject
            finished += 1
            self.onFinishIfNeeded()
        case .onError(let error, let index):
            saveMediumStates[index].savedMedium = nil
            saveMediumStates[index].savedError = error.localizedDescription
            finished += 1
            self.onFinishIfNeeded()
        }
    }
    
    func onFinishIfNeeded() {
        if allFinished {
            trigger = false
            let failState = saveMediumStates.first(where: { $0.savedError != nil })
            let allSuccess = failState == nil
            if allSuccess {
                success = ""
            } else {
                error = failState?.savedError
            }
        }
    }
}
