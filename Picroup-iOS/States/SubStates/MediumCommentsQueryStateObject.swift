//
//  MediumCommentsQueryStateObject.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/9/3.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RealmSwift

final class MediumCommentsQueryStateObject: CursorCommentsQueryStateObject {}
extension MediumCommentsQueryStateObject {
    func query(mediumId: String) -> MediumCommentsQuery? {
        return trigger
            ? MediumCommentsQuery(mediumId: mediumId, cursor: cursorComments?.cursor.value)
            : nil
    }
}

