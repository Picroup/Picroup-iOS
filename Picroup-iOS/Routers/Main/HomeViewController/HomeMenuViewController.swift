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

class HomeMenuViewController: FABMenuController {
    
    init() {
        super.init(rootViewController: HomeViewController())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate var homeMenuPresenter: HomeMenuPresenter!
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fabMenuBacking = .fade
        homeMenuPresenter = HomeMenuPresenter(view: view, fabMenu: fabMenu)
        
        homeMenuPresenter.fabMenu.delegate = nil
        
        homeMenuPresenter.fabMenu.rx.fabMenuWillOpen
            .bind(to: homeMenuPresenter.fabMenu.fabButton!.rx.animate(.rotate(45)))
            .disposed(by: disposeBag)
        
        homeMenuPresenter.fabMenu.rx.fabMenuWillClose
            .bind(to: homeMenuPresenter.fabMenu.fabButton!.rx.animate(.rotate(0)))
            .disposed(by: disposeBag)
        
        homeMenuPresenter.cameraFABMenuItem.fabButton.rx.tap
            .asDriver()
            .drive(Binder(self) { (me, _) in
                me.homeMenuPresenter.fabMenu.delegate?.fabMenuWillClose?(fabMenu: me.homeMenuPresenter.fabMenu)
                me.homeMenuPresenter.fabMenu.close()
            })
            .disposed(by: disposeBag)
    }
}
