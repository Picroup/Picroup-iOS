//
//  HomeViewController.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/9.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import Material
import RxSwift
import RxCocoa

class HomeViewController: FABMenuController {
    
    fileprivate var homePresenter: HomePresenter!
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fabMenuBacking = .fade
        homePresenter = HomePresenter(view: view, fabMenu: fabMenu)
        
        homePresenter.fabMenu.delegate = nil
        
        homePresenter.fabMenu.rx.fabMenuWillOpen
            .bind(to: homePresenter.fabMenu.fabButton!.rx.animate(.rotate(45)))
            .disposed(by: disposeBag)
        
        homePresenter.fabMenu.rx.fabMenuWillClose
            .bind(to: homePresenter.fabMenu.fabButton!.rx.animate(.rotate(0)))
            .disposed(by: disposeBag)
    }
}
