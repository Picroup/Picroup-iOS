//
//  SaveMediumStateObject.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/23.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation

final class SaveMediumStateObject: PrimaryObject {
    
    @objc dynamic var progress: RxProgressObject?
    @objc dynamic var savedMedium: MediumObject?
    @objc dynamic var savedError: String?
}
