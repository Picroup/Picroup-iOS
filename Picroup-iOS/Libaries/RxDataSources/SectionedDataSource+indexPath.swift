//
//  SectionedDataSource+indexPath.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/10.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RxDataSources

extension CollectionViewSectionedDataSource {
    
    public subscript(section: Int) -> S {
        return sectionModels[section]
    }
    
    public subscript(indexPath: IndexPath) -> S.Item {
        return sectionModels[indexPath.section].items[indexPath.item]
    }
}

extension TableViewSectionedDataSource {
    
    public subscript(section: Int) -> S {
        return sectionModels[section]
    }
    
    public subscript(indexPath: IndexPath) -> S.Item {
        return sectionModels[indexPath.section].items[indexPath.item]
    }
}
