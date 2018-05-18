//
//  IsFeedbackStateObject.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/15.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RealmSwift

public protocol IsFeedbackStateObject {
    associatedtype Event
    func reduce(event: Event, realm: Realm)
}
