//
//  HomeViewController.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/10.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import Material
import RxSwift
import RxCocoa
import RxFeedback
import RxDataSources

class HomeViewController: UIViewController {
    
    typealias Dependency = (state: Driver<HomeState>, events: (HomeState.Event) -> Void)
    var dependency: Dependency!
    
    @IBOutlet var presenter: HomeViewPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        typealias Section = HomeViewPresenter.Section
        
        guard let (state, events) = dependency else { return }
        typealias Feedback = (Driver<HomeState>) -> Signal<HomeState.Event>

        let uiFeedback: Feedback = bind(self) { (me, state) in
            let _events = PublishRelay<HomeState.Event>()
            let subscriptions = [
                state.map { [Section(model: "", items: $0.items)] }.drive(me.presenter.items(_events))
            ]
            let events: [Signal<HomeState.Event>] = [
                state.flatMapLatest {
                    $0.shouldQueryMore ? me.presenter.collectionView.rx.isNearBottom.asSignal() : .empty()
                    }.map { .onTriggerGetMore },
                _events.asSignal(),
            ]
            return Bindings(subscriptions: subscriptions, events: events)
        }
        
        let vcFeedback: Feedback = bind(self) { (me, state)  in
            let subscriptions = [
                me.presenter.collectionView.rx.shouldHideNavigationBar()
                    .emit(to: me.rx.setNavigationBarHidden(animated: true))
            ]
            let events: [Signal<HomeState.Event>] = [
                .never(),
                ]
            return Bindings(subscriptions: subscriptions, events: events)
        }
        
        Signal.merge(uiFeedback(state), vcFeedback(state))
            .emit(onNext: events)
            .disposed(by: disposeBag)
        
        presenter.collectionView.rx.setDelegate(presenter)
            .disposed(by: disposeBag)
    }
}
