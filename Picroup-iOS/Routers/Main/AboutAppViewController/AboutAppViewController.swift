//
//  AboutAppViewController.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/6/12.
//  Copyright © 2018年 luojie. All rights reserved.
//


import UIKit

final class AboutAppViewController: ShowNavigationBarViewController {
//    @IBOutlet weak var headerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.titleLabel.text = "关于"
        navigationItem.titleLabel.textColor = .primaryText
    }
}
