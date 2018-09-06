//
//  CodeValidQueryStateObject.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/9/2.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RealmSwift

final class CodeValidQueryStateObject: QueryStateObject {}

extension CodeValidQueryStateObject {
    func query(code: Double?) -> Double? {
        return trigger ? code : nil
    }
}
