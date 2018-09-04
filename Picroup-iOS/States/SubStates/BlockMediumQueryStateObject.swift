//
//  BlockMediumQueryStateObject.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/9/4.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RealmSwift

final class BlockMediumQueryStateObject: QueryStateObject {}
extension BlockMediumQueryStateObject {
    func query(userId: String?, mediumId: String) -> BlockMediumMutation? {
        guard let userId = userId else { return nil }
        return trigger
            ? BlockMediumMutation(userId: userId, mediumId: mediumId)
            : nil
    }
}
