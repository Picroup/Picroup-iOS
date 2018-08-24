//
//  MediumObject.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/14.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift
import Apollo

final class MediumObject: PrimaryObject {
    
    @objc dynamic fileprivate(set) var userId: String?
    @objc dynamic fileprivate(set) var detail: MediumDetailObject?
    @objc dynamic fileprivate(set) var url: String?
    @objc dynamic fileprivate(set) var kind: String?
    let createdAt = RealmOptional<Double>()
    let endedAt = RealmOptional<Double>()
    let stared = RealmOptional<Bool>()
    let commentsCount = RealmOptional<Int>()
    let tags = List<String>()

    @objc dynamic fileprivate(set) var user: UserObject?
}

extension MediumObject {
    enum Event {
        case onStared(TimeInterval)
    }
}

extension MediumObject: IsFeedbackStateObject {
    
    func reduce(event: Event, realm: Realm) {
        switch event {
        case .onStared(let endedAt):
            stared.value = true
            self.endedAt.value = endedAt
        }
    }
}
