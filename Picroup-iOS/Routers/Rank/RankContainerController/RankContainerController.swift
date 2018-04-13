//
//  RankToolBarController.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/13.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import Material

class RankContainerController: ToolbarController {
    fileprivate var categoryButton: IconButton!
    fileprivate let tabBar = TabBar()

    override func prepare() {
        super.prepare()
        prepareCategoryButton()
        prepareStatusBar()
        prepareToolbar()
//        prepareTabBar()
    }
}

extension RankContainerController {
    
    fileprivate func prepareCategoryButton() {
        categoryButton = IconButton(image: Icon.cm.arrowDownward, tintColor: .primaryText)
        categoryButton.pulseColor = .white
    }
    
    fileprivate func prepareStatusBar() {
        statusBarStyle = .lightContent
        statusBar.backgroundColor = .primaryDark
    }
    
    fileprivate func prepareToolbar() {
        toolbar.depthPreset = .none
        toolbar.backgroundColor = .primary
    
        toolbar.title = "全部"
        toolbar.titleLabel.textColor = .primaryText
        toolbar.titleLabel.textAlignment = .left
        
        toolbar.leftViews = [categoryButton]
    }
    
    fileprivate func prepareTabBar() {
        
        let t1 = TabItem(title: "周榜")
        t1.titleColor = .primaryText
        let t2 = TabItem(title: "总榜")
        t2.titleColor = .primaryText
        
        tabBar.tabItems = [t1, t2]
        tabBar.isDividerHidden = true
        tabBar.lineAlignment = .bottom
        tabBar.setLineColor(.primaryLight, for: .selected)
        tabBar.backgroundColor = .primary
        
        view.layout(tabBar).top(64).horizontally()
    }
}
