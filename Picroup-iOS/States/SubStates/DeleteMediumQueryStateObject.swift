//
//  DeleteMediumQueryStateObject.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/9/4.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RealmSwift

final class DeleteMediumQueryStateObject: QueryStateObject {}
extension DeleteMediumQueryStateObject {
    func query(mediumId: String) -> DeleteMediumMutation? {
        return trigger
            ? DeleteMediumMutation(mediumId: mediumId)
            : nil
    }
}
