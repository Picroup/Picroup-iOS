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
        
        uiFeedback(state)
            .emit(onNext: events)
            .disposed(by: disposeBag)
        
        presenter.collectionView.rx.setDelegate(presenter)
            .disposed(by: disposeBag)
        
        presenter.collectionView.rx.willEndDragging.asSignal()
            .map { $0.velocity.y >= 0 }
            .emit(onNext: { [weak self] in
                self?.navigationController?.setNavigationBarHidden($0, animated: true)
            })
            .disposed(by: disposeBag)
    }
}
