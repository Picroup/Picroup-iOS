//
//  CollectionViewLayoutManager.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/6/11.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit

struct CollectionViewLayoutManager {
    
//    private static var cachedSize = [CGFloat: CGSize]()
//
//    static func size(in bounds: CGRect) -> CGSize {
//        if let cached = self.cachedSize[bounds.width] {
//            return cached
//        }
//        let cellMiniWidth: CGFloat = (320 - 2 * 3) / 2
//        let length = bounds.width - 2
//        let count = Int(length / (cellMiniWidth + 2))
//        let cellWidth = length / CGFloat(count) - 2
//        let size = CGSize(width: cellWidth, height: cellWidth)
//        self.cachedSize[bounds.width] = size
//        return size
//    }
    
    static func size(in bounds: CGRect, aspectRatio: Double) -> CGSize {

        let cellWidth = bounds.width - 4
        let cellHeight = cellWidth / CGFloat(aspectRatio) + 4
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
}
