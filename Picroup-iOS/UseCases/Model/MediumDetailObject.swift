//
//  MediumDetailObject.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/24.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift

final class MediumDetailObject: Object {
    let width = RealmOptional<Double>()
    let aspectRatio = RealmOptional<Double>()
    @objc dynamic var videoURL: String?
    @objc dynamic var placeholderColor: String?
}
