//
//  StarMediumQueryStateObject.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/9/4.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RealmSwift

final class StarMediumQueryStateObject: QueryStateObject {}
extension StarMediumQueryStateObject {
    func query(userId: String?, mediumId: String) -> StarMediumMutation? {
        guard let userId = userId else { return nil }
        return trigger
            ? StarMediumMutation(userId: userId, mediumId: mediumId)
            : nil
    }
}
