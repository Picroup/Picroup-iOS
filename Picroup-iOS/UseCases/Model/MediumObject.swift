//
//  MediumObject.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/14.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift

class MediumObject: PrimaryObject {
    
    @objc dynamic var userId: String?
    let createdAt = RealmOptional<Double>()
    let endedAt = RealmOptional<Double>()
    @objc dynamic var detail: MediumDetailObject?
    @objc dynamic var minioId: String?
    let commentsCount = RealmOptional<Int>()
    
    @objc dynamic var user: UserObject?
}

class MediumDetailObject: Object {
    let width = RealmOptional<Double>()
    let aspectRatio = RealmOptional<Double>()
}

class CursorMedia: PrimaryObject {
    
    let cursor = RealmOptional<Double>()
    let items = List<MediumObject>()
}

