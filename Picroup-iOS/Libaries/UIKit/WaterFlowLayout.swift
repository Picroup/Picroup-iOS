//
//  WaterFlowLayout.swift
//  WaterflowLayout
//
//  Created by ovfun on 2018/9/10.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit

protocol WaterFlowLayoutDelegate: AnyObject {
    func collectionView(_ collectionView: UICollectionView, heightForItemAtIndexPath indexPath: IndexPath, withWidth width: CGFloat) -> CGFloat
}

class WaterFlowLayout: UICollectionViewLayout {
    
    struct Configuration {
        var minCellWidth: CGFloat = 196
        var cellSpace: CGFloat = 8
        var lineSpace: CGFloat = 8
    }
    
    init(configuration: Configuration = .init()) {
        self.configuration = configuration
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.configuration = .init()
        super.init(coder: aDecoder)
    }
    
    weak var delegate: WaterFlowLayoutDelegate?
    var configuration: Configuration
    fileprivate var cache = [UICollectionViewLayoutAttributes]()
    fileprivate var supplementaryViewCache = [UICollectionViewLayoutAttributes]()
    fileprivate var _collectionViewContentSize: CGSize = .zero

}

extension WaterFlowLayout {
    
    override func prepare() {
        guard let delegate = delegate else {
            print("WaterFlowLayout delegate is not set!")
            return
        }
        
        guard let collectionView = collectionView else {
            print("WaterFlowLayout collectionView is nil")
            return
        }
        
        guard collectionView.numberOfSections > 0 else {
            return
        }
        
        resetCollectionViewContentSize(collectionView)
        cache.removeAll()
        supplementaryViewCache.removeAll()
        
        let collectionViewWidth = collectionView.bounds.width
        
        let (columnCount, cellWidth, cellUnitWidth): (Int, CGFloat, CGFloat) = {
            let cellUnitsWidth = collectionViewWidth - configuration.cellSpace
            let minCellUnitsWidth = configuration.minCellWidth + configuration.cellSpace
            let columnCount = max(2, Int(cellUnitsWidth / minCellUnitsWidth))
            let cellUnitWidth = cellUnitsWidth / CGFloat(columnCount)
            let cellWidth = cellUnitWidth - configuration.cellSpace
            return (columnCount, cellWidth, cellUnitWidth)
        }()
        
        let xOffsets = (0..<columnCount).map { column in cellUnitWidth * CGFloat(column) }
        var yOffsets = [CGFloat](repeating: 0, count: columnCount)
        var column = 0
        
        for item in (0..<collectionView.numberOfItems(inSection: 0)) {
            let indexPath = IndexPath(item: item, section: 0)
            
            let cellFrame: CGRect = {
                let x = xOffsets[column] + configuration.cellSpace
                let y = yOffsets[column] + configuration.lineSpace
                let cellHeight = delegate.collectionView(collectionView, heightForItemAtIndexPath: indexPath, withWidth: cellWidth)
                return CGRect(x: x, y: y, width: cellWidth, height: cellHeight)
            }()
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = cellFrame
            cache.append(attributes)
            
            yOffsets[column] = cellFrame.maxY
            _collectionViewContentSize.height = {
                let columnMaxY = cellFrame.maxY + configuration.lineSpace
                return max(_collectionViewContentSize.height, columnMaxY + 80)
            }()
            column = {
                let minYColumn = yOffsets.enumerated().min(by: { $0.element < $1.element})?.offset
                return minYColumn ?? 0
            }()
        }
        
        let indexPath = IndexPath(item: 0, section: 0)
        let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, with: indexPath)
        attributes.frame = CGRect(
            x: 0, y: _collectionViewContentSize.height - 80,
            width: collectionViewWidth, height: 80
        )
        supplementaryViewCache.append(attributes)
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.item]
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return [cache, supplementaryViewCache].lazy
            .flatMap { $0 }
            .filter { $0.frame.intersects(rect) }
    }
    
    override var collectionViewContentSize: CGSize {
        return _collectionViewContentSize
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return supplementaryViewCache[indexPath.section]
    }
}

extension WaterFlowLayout {
    
    fileprivate func resetCollectionViewContentSize(_ collectionView: UICollectionView) {
        let contentInset = collectionView.contentInset
        let width = collectionView.bounds.width - (contentInset.left + contentInset.right)
        _collectionViewContentSize = CGSize(width: width, height: 0)
    }
}
