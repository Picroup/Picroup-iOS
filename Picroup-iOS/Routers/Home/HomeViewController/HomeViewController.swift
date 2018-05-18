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
import Apollo

class HomeViewController: UIViewController {
    
//    typealias Dependency = (state: Driver<HomeState>, events: (HomeState.Event) -> Void)
//    var dependency: Dependency!
    
    typealias Feedback = (Driver<MyInterestedMediaStateObject>) -> Signal<MyInterestedMediaStateObject.Event>
    @IBOutlet var presenter: HomeViewPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRxFeedback()
    }
    
    private func setupRxFeedback() {
        
        typealias Section = HomeViewPresenter.Section
        
        guard let store = try? MyInterestedMediaStateStore() else { return }
        
        let uiFeedback: Feedback = bind(self) { (me, state) in
            let presenter = me.presenter!
            let _events = PublishRelay<MyInterestedMediaStateObject.Event>()
            let subscriptions = [
                store.myInterestedMediaItems().map { [Section(model: "", items: $0)] }.drive(me.presenter.items(_events)),
                state.map { $0.isReloading }.drive(presenter.refreshControl.rx.isRefreshing),
                presenter.collectionView.rx.shouldHideNavigationBar().emit(to: me.rx.setNavigationBarHidden(animated: true))
            ]
            let events: [Signal<MyInterestedMediaStateObject.Event>] = [
                state.flatMapLatest {
                    $0.shouldQueryMoreMyInterestedMedia
                        ? presenter.collectionView.rx.triggerGetMore
                        : .empty()
                    }.map { .onTriggerGetMoreMyInterestedMedia },
                presenter.refreshControl.rx.controlEvent(.valueChanged).asSignal().map { .onTriggerReloadMyInterestedMedia },
                .just(.onTriggerReloadMyInterestedMedia),
                _events.asSignal(),
                ]
            return Bindings(subscriptions: subscriptions, events: events)
        }
        
        let queryMyInterestedMedia: Feedback = react(query: { $0.myInterestedMediaQuery }) { query in
            ApolloClient.shared.rx.fetch(query: query, cachePolicy: .fetchIgnoringCacheData)
                .map { $0?.data?.user?.interestedMedia.fragments.cursorMediaFragment }.unwrap()
                .map(MyInterestedMediaStateObject.Event.onGetMyInterestedMedia(isReload: query.cursor == nil))
                .asSignal(onErrorReturnJust: MyInterestedMediaStateObject.Event.onGetMyInterestedMediaError)
        }
        
        let states = store.states
        
        Signal.merge(
            uiFeedback(states),
            queryMyInterestedMedia(states)
            )
            .debug("MyInterestedMediaStateObject.Event", trimOutput: true)
            .emit(onNext: store.on)
            .disposed(by: disposeBag)
        
        //        guard let (state, events) = dependency else { return }
        //        typealias Feedback = (Driver<HomeState>) -> Signal<HomeState.Event>
        
        //        let uiFeedback: Feedback = bind(self) { (me, state) in
        //            let _events = PublishRelay<HomeState.Event>()
        //            let subscriptions = [
        //                state.map { [Section(model: "", items: $0.items)] }.drive(me.presenter.items(_events))
        //            ]
        //            let events: [Signal<HomeState.Event>] = [
        //                state.flatMapLatest {
        //                    $0.shouldQueryMore ? me.presenter.collectionView.rx.isNearBottom.asSignal() : .empty()
        //                    }.map { .onTriggerGetMore },
        //                _events.asSignal(),
        //            ]
        //            return Bindings(subscriptions: subscriptions, events: events)
        //        }
        //
        //        let vcFeedback: Feedback = bind(self) { (me, state)  in
        //            let subscriptions = [
        //                me.presenter.collectionView.rx.shouldHideNavigationBar()
        //                    .emit(to: me.rx.setNavigationBarHidden(animated: true))
        //            ]
        //            let events: [Signal<HomeState.Event>] = [
        //                .never(),
        //                ]
        //            return Bindings(subscriptions: subscriptions, events: events)
        //        }
        //
        //        Signal.merge(uiFeedback(state), vcFeedback(state))
        //            .emit(onNext: events)
        //            .disposed(by: disposeBag)
        
        presenter.collectionView.rx.setDelegate(presenter)
            .disposed(by: disposeBag)
        
    }
}
