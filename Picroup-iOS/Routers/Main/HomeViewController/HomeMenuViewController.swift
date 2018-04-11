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
import RxFeedback

class HomeMenuViewController: FABMenuController {
    
    init() {
        super.init(rootViewController: HomeViewController())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate var homeMenuPresenter: HomeMenuPresenter!
    private let disposeBag = DisposeBag()
    typealias Feedback = (Driver<HomeState>) -> Signal<HomeState.Event>

    override func viewDidLoad() {
        super.viewDidLoad()

        fabMenuBacking = .fade
        homeMenuPresenter = HomeMenuPresenter(view: view, fabMenu: fabMenu)
        homeMenuPresenter.fabMenu.delegate = nil
        
        let uiFeedback: Feedback = bind(homeMenuPresenter) { (presenter, state) in
            let subscriptions = [
                state.map { $0.isFABMenuOpened }.distinctUntilChanged().drive(presenter.isFABMenuOpened),
                state.map { $0.triggerFABMenuClose }.distinctUntilChanged { $0 != nil }.unwrap().drive(presenter.fabMenu.rx.close()),

                ]
            let events = [
                presenter.fabMenu.rx.fabMenuWillOpen.map { HomeState.Event.fabMenuWillOpen },
                presenter.fabMenu.rx.fabMenuWillClose.map { HomeState.Event.fabMenuWillClose },
                presenter.cameraFABMenuItem.fabButton.rx.tap.map { HomeState.Event.triggerFABMenuClose },
            ]
            return Bindings(subscriptions: subscriptions, events: events)
        }
        
        Driver<Any>.system(
            initialState: HomeState.empty,
            reduce: logger(identifier: "HomeState")(HomeState.reduce),
            feedback: uiFeedback
        )
        .drive()
        .disposed(by: disposeBag)
    }
}
