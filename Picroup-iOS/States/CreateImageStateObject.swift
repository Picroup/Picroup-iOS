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

final class CreateImageStateObject: PrimaryObject {
    typealias Query = (userId: String, imageKey: String)

    @objc dynamic var session: UserSessionObject?
    
    @objc dynamic var progress: RxProgressObject?
    @objc dynamic var savedMedium: MediumObject?
    @objc dynamic var savedError: String?
    @objc dynamic var triggerSaveMediumQuery: Bool = false

    @objc dynamic var myMedia: CursorMediaObject?
    @objc dynamic var myInterestedMedia: CursorMediaObject?

}

extension CreateImageStateObject {
    var imageKey: String { return _id }
    var saveQuery: Query? {
        guard let userId = session?.currentUser?._id else { return nil }
        return triggerSaveMediumQuery ? (userId: userId, imageKey: _id) : nil
    }
    var shouldSaveMedium: Bool {
        return !triggerSaveMediumQuery && savedMedium == nil
    }
}


extension CreateImageStateObject {
    
    static func create(imageKey: String) -> (Realm) throws -> CreateImageStateObject {
        return { realm in
            let _id = PrimaryKey.default
            let value: Any = [
                "_id": imageKey,
                "session": ["_id": _id],
                "progress": [:],
                "myMedia": ["_id": PrimaryKey.myMediaId],
                "myInterestedMedia": ["_id": PrimaryKey.myInterestedMediaId],
                ]
            return try realm.findOrCreate(CreateImageStateObject.self, forPrimaryKey: imageKey, value: value)
        }
    }
}

extension CreateImageStateObject {
    enum Event {
        case onTriggerSaveMedium
        case onProgress(RxProgress)
        case onSavedMediumSuccess(MediumFragment)
        case onSavedMediumError(Error)
//        case triggerCancel
    }
}

extension CreateImageStateObject: IsFeedbackStateObject {
    
    func reduce(event: Event, realm: Realm) {
        switch event {
        case .onTriggerSaveMedium:
            guard shouldSaveMedium else { return }
            triggerSaveMediumQuery = true
        case .onProgress(let progress):
            self.progress?.bytesWritten = Int(progress.bytesWritten)
            self.progress?.totalBytes = Int(progress.totalBytes)
        case .onSavedMediumSuccess(let medium):
            let mediumObject = realm.create(MediumObject.self, value: medium.snapshot, update: true)
            savedMedium = mediumObject
            myMedia?.items.insert(mediumObject, at: 0)
            myInterestedMedia?.items.insert(mediumObject, at: 0)
            triggerSaveMediumQuery = false
        case .onSavedMediumError(let error):
            savedMedium = nil
            savedError = error.localizedDescription
            triggerSaveMediumQuery = false
        }
    }
}

final class CreateImageStateStore {
    
    let states: Driver<CreateImageStateObject>
    private let _state: CreateImageStateObject
    private let imageKey: String
    
    init(imageKey: String) throws {
        let realm = try Realm()
        let _state = try CreateImageStateObject.create(imageKey: imageKey)(realm)
        let states = Observable.from(object: _state).asDriver(onErrorDriveWith: .empty())
        
        self.imageKey = imageKey
        self._state = _state
        self.states = states
    }
    
    func on(event: CreateImageStateObject.Event) {
        Realm.backgroundReduce(ofType: CreateImageStateObject.self, forPrimaryKey: imageKey, event: event)
    }
}
