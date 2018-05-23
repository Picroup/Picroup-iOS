//
//  SearchUserPresenter.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/23.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import Material

final class SearchUserPresenter: NSObject {
    
    weak var navigationItem: UINavigationItem!
    @IBOutlet weak var searchBar: UISearchBar!
    
    func setup(navigationItem: UINavigationItem) {
        self.navigationItem = navigationItem
        searchBar.becomeFirstResponder()
        prepareNavigationItem()
    }
    
    fileprivate func prepareNavigationItem() {
        navigationItem.titleLabel.text = "搜索用户"
        navigationItem.titleLabel.textColor = .primaryText
    }
}
