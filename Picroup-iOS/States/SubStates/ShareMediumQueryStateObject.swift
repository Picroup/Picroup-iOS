//
//  ShareMediumQueryStateObject.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/9/4.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RealmSwift

final class ShareMediumQueryStateObject: QueryStateObject {}
extension ShareMediumQueryStateObject {
    typealias Query = (username: String, mediumItem: MediumItem)
    func query(medium: MediumObject?) -> Query? {
        guard trigger else { return nil }
        guard let username = medium?.user?.username,
            let mediumItem = MediumItemHelper.mediumItem(from: medium) else { return nil }
        return (username, mediumItem)
    }
}
