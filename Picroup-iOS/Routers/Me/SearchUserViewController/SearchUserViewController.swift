//
//  SearchUserViewController.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/23.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import Material

final class SearchUserViewController: ShowNavigationBarViewController {
    
    @IBOutlet var presenter: SearchUserPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPresenter()
        setupRxFeedback()
    }
    
    private func setupPresenter() {
        presenter.setup(navigationItem: navigationItem)
    }
    
    private func setupRxFeedback() {
        
    }
}
