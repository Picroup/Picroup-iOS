//
//  NeedUpdateStateObject.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/7/23.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RealmSwift

final class NeedUpdateStateObject: PrimaryObject {
    @objc dynamic var myInterestedMedia: Bool = false
    @objc dynamic var myMedia: Bool = false
    @objc dynamic var myStaredMedia: Bool = false
}
