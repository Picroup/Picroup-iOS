//
//  RxProgressObject.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/23.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift

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
