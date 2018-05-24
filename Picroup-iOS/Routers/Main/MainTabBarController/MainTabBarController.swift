//
//  MainTabBarController.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/10.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import Apollo
import RxSwift
import RxCocoa
import RxDataSources
import RxFeedback

final class MainTabBarController: UITabBarController {
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.setup()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        tabBar.isTranslucent = false
//        hidesBottomBarWhenPushed = true
        delegate = self
    }
    
    fileprivate typealias Feedback = (Driver<MainStateObject>) -> Signal<MainStateObject.Event>
    fileprivate lazy var _events = PublishRelay<MainStateObject.Event>()
    fileprivate var store: MainStateStore?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupRxFeedback()
    }
    
    private func setupRxFeedback() {
        
        guard let store = try? MainStateStore() else { return }
        self.store = store

        let uiFeedback: Feedback = bind(self) { (me, state)  in
            let subscriptions: [Disposable] = []
            let events: [Signal<MainStateObject.Event>] = [me._events.asSignal()]
            return Bindings(subscriptions: subscriptions, events: events)
        }
        
        let states = store.states
        
        Signal.merge(
            uiFeedback(states)
            )
            .debug("MainStateObject.Event", trimOutput: true)
            .emit(onNext: store.on)
            .disposed(by: disposeBag)
    }
}

extension MainTabBarController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let isLogin = store?.state.session?.isLogin ?? false
        if isLogin {
            return true
        } else {
            _events.accept(.onTriggerLogin)
            return false
        }
    }
}
