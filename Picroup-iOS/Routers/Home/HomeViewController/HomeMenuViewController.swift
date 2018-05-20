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
import Apollo

class HomeMenuViewController: FABMenuController {
    
    fileprivate typealias Feedback = (Driver<HomeStateObject>) -> Signal<HomeStateObject.Event>
    fileprivate var homeMenuPresenter: HomeMenuPresenter!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPresenter()
        setupRxFeedback()
    }
    
    private func setupPresenter() {
        fabMenuBacking = .fade
        homeMenuPresenter = HomeMenuPresenter(view: view, fabMenu: fabMenu, navigationItem: navigationItem)
    }
    
    private func setupRxFeedback() {
        
        guard let store = try? HomeStateStore() else { return }
        
        let uiFeedback: Feedback = bind(homeMenuPresenter) { (presenter, state) in
            let subscriptions = [
                state.map { $0.isFABMenuOpened }.distinctUntilChanged().drive(presenter.isFABMenuOpened),
                state.map { $0.triggerFABMenuCloseVersion }.distinctUnwrap().mapToVoid().drive(presenter.fabMenu.rx.close()),
                ]
            let events: [Signal<HomeStateObject.Event>] = [
                presenter.fabMenu.rx.fabMenuWillOpen.asSignal().map { HomeStateObject.Event.fabMenuWillOpen },
                presenter.fabMenu.rx.fabMenuWillClose.asSignal().map { HomeStateObject.Event.fabMenuWillClose },
                presenter.cameraFABMenuItem.fabButton.rx.tap.asSignal().map { HomeStateObject.Event.triggerFABMenuClose },
                presenter.cameraFABMenuItem.fabButton.rx.tap.asSignal().map { HomeStateObject.Event.triggerPickImage(.camera) },
                presenter.photoFABMenuItem.fabButton.rx.tap.asSignal().map { HomeStateObject.Event.triggerFABMenuClose },
                presenter.photoFABMenuItem.fabButton.rx.tap.asSignal().map { HomeStateObject.Event.triggerPickImage(.photoLibrary) },
                ]
            return Bindings(subscriptions: subscriptions, events: events)
        }
        
        let states = store.states
        
        Signal.merge(
            uiFeedback(states)
            )
            .debug("HomeStateObject.Event", trimOutput: true)
            .emit(onNext: store.on)
            .disposed(by: disposeBag)
    }
    
}

