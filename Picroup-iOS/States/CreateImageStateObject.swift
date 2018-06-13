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

final class CreateImageStateObject: PrimaryObject {
    typealias Query = (userId: String, imageKeys: [String])

    @objc dynamic var session: UserSessionObject?
    
    let imageKeys = List<String>()
    let saveMediumStates = List<SaveMediumStateObject>()
    @objc dynamic var finished: Int = 0
    @objc dynamic var triggerSaveMediumQuery: Bool = false

    @objc dynamic var myMedia: CursorMediaObject?
    @objc dynamic var myInterestedMedia: CursorMediaObject?
    
    @objc dynamic var needUpdate: NeedUpdateStateObject?

    @objc dynamic var popRoute: PopRouteObject?
    
    @objc dynamic var snackbar: SnackbarObject?
}

extension CreateImageStateObject {
    var saveQuery: Query? {
        guard let userId = session?.currentUser?._id else { return nil }
        return triggerSaveMediumQuery ? (userId: userId, imageKeys: imageKeys.toArray()) : nil
    }
    var shouldSaveMedium: Bool {
        return !triggerSaveMediumQuery
    }
    var allFinished: Bool { return finished == imageKeys.count }
}

extension CreateImageStateObject {
    
    static func create(imageKeys: [String]) -> (Realm) throws -> CreateImageStateObject {
        return { realm in
            let _id = PrimaryKey.default
            let value: Any = [
                "_id": _id,
                "session": ["_id": _id],
                "imageKeys": imageKeys,
                "saveMediumStates": imageKeys.map { ["_id": $0, "progress": [:]] },
                "finished": 0,
                "myMedia": ["_id": PrimaryKey.myMediaId],
                "myInterestedMedia": ["_id": PrimaryKey.myInterestedMediaId],
                "needUpdate": ["_id": _id],
                "popRoute": ["_id": _id],
                "snackbar": ["_id": _id],
                ]
            return try realm.update(CreateImageStateObject.self, value: value)
        }
    }
}

extension CreateImageStateObject {
    enum Event {
        case onTriggerSaveMedium
        case onProgress(RxProgress, Int)
        case onSavedMediumSuccess(MediumFragment, Int)
        case onSavedMediumError(Error, Int)
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
        }
    }
}

final class CreateImageStateStore {
    
    let states: Driver<CreateImageStateObject>
    private let _state: CreateImageStateObject
    
    init(imageKeys: [String]) throws {
        let realm = try Realm()
        let _state = try CreateImageStateObject.create(imageKeys: imageKeys)(realm)
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
}
