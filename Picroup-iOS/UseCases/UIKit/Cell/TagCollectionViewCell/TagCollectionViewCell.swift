//
//  TagCollectionViewCell.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/7/19.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit

final class TagCollectionViewCell: RxCollectionViewCell {
    @IBOutlet weak var tagLabel: UILabel!
    
    func setSelected(_ selected: Bool) {
        backgroundColor = selected ? .primaryLight : .secondaryLightText
    }
}
