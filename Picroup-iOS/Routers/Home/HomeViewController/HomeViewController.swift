//
//  MyInterestedMediaViewController.swift
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

class HomeViewController: UIViewController {
    
    fileprivate typealias Feedback = (Driver<HomeStateObject>) -> Signal<HomeStateObject.Event>
    @IBOutlet var presenter: HomeViewPresenter!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupRxFeedback()
    }
    
    private func setupRxFeedback() {
        
        presenter.setup(navigationItem: navigationItem)
        typealias Section = HomeViewPresenter.Section

        guard let store = try? HomeStateStore() else { return }
        
        let uiFeedback: Feedback = bind(self) { (me, state) in
            let presenter = me.presenter!
            let _events = PublishRelay<HomeStateObject.Event>()
            let footerState = PublishRelay<LoadFooterViewState>()
            let subscriptions = [
                store.myInterestedMediaItems().map { [Section(model: "", items: $0)] }.drive(presenter.items(_events, footerState.asSignal())),
                state.map { $0.isReloading }.drive(presenter.refreshControl.rx.isRefreshing),
                state.map { $0.footerState }.asSignalOnErrorRecoverEmpty().emit(to: footerState),
                presenter.collectionView.rx.shouldHideNavigationBar().emit(to: me.rx.setNavigationBarHidden(animated: true)),
            ]
            let events: [Signal<HomeStateObject.Event>] = [
                .just(.onTriggerReloadMyInterestedMedia),
                _events.asSignal(),
                state.flatMapLatest {
                    $0.shouldQueryMoreMyInterestedMedia
                        ? presenter.collectionView.rx.triggerGetMore
                        : .empty()
                    }.map { .onTriggerGetMoreMyInterestedMedia },
                presenter.refreshControl.rx.controlEvent(.valueChanged).asSignal().map { .onTriggerReloadMyInterestedMedia },
                presenter.fabButton.rx.tap.asSignal().map { .onTriggerPickImage },
                presenter.addUserButton.rx.tap.asSignal().map { .onTriggerSearchUser },
                ]
            return Bindings(subscriptions: subscriptions, events: events)
        }
        
        let queryMyInterestedMedia: Feedback = react(query: { $0.myInterestedMediaQuery }) { query in
            ApolloClient.shared.rx.fetch(query: query, cachePolicy: .fetchIgnoringCacheData)
                .map { $0?.data?.user?.interestedMedia.fragments.cursorMediaFragment }.unwrap()
                .map(HomeStateObject.Event.onGetMyInterestedMedia(isReload: query.cursor == nil))
                .asSignal(onErrorReturnJust: HomeStateObject.Event.onGetMyInterestedMediaError)
        }
        
        let states = store.states
        
        Signal.merge(
            uiFeedback(states),
            queryMyInterestedMedia(states)
            )
            .debug("HomeState.Event", trimOutput: true)
            .emit(onNext: store.on)
            .disposed(by: disposeBag)
        
        presenter.collectionView.rx.setDelegate(presenter)
            .disposed(by: disposeBag)
    }
    
}

extension HomeStateObject {
    
    var footerState: LoadFooterViewState {
        let (cursor, trigger, error) = (myInterestedMedia?.cursor.value, triggerMyInterestedMediaQuery, myInterestedMediaError)
        return LoadFooterViewState.create(cursor: cursor, trigger: trigger, error: error)
    }
}

