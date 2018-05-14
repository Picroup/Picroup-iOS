//
//  NotificationObject.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/14.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift
import Apollo

class NotificationObject: PrimaryObject {
    @objc dynamic var userId: String?
    @objc dynamic var toUserId: String?
    @objc dynamic var mediumId: String?
    @objc dynamic var content: String?
    
    let createdAt = RealmOptional<Double>()
    let endedAt = RealmOptional<Double>()
    let viewed = RealmOptional<Bool>()
    
    @objc dynamic var user: UserObject?
    @objc dynamic var medium: MediumObject?
}

class CursorNotifications: PrimaryObject {
    
    let cursor = RealmOptional<Double>()
    let items = List<NotificationObject>()
}

extension CursorNotifications: IsCursorItemsObject {
    typealias CursorItemsFragment = CursorNotoficationsFragment
}

extension CursorNotoficationsFragment: IsCursorFragment {}
