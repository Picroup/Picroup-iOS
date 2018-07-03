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

class HomeViewController: BaseViewController {
    
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
        
        weak var weakSelf = self
        let uiFeedback: Feedback = bind(self) { (me, state) in
            let presenter = me.presenter!
            let _events = PublishRelay<HomeStateObject.Event>()
            let footerState = BehaviorRelay<LoadFooterViewState>(value: .empty)
            let subscriptions = [
                store.myInterestedMediaItems().map { [Section(model: "", items: $0)] }.drive(presenter.items(_events, footerState.asDriver())),
                state.map { $0.isReloading }.drive(presenter.refreshControl.rx.isRefreshing),
                state.map { $0.footerState }.drive(footerState),
                state.map { $0.isMyInterestedMediaEmpty }.drive(presenter.isMyInterestedMediaEmpty),
                presenter.fabButton.rx.tap.asSignal().map { false }.emit(to: me.rx.setNavigationBarHidden(animated: true)),
                presenter.collectionView.rx.shouldHideNavigationBar().emit(to: me.rx.setNavigationBarHidden(animated: true)),
                ]
            let events: [Signal<HomeStateObject.Event>] = [
                .just(.onTriggerReloadMyInterestedMedia),
                _events.asSignal(),
                me.rx.viewWillAppear.asSignal().map { _ in .onTriggerReloadMyInterestedMediaIfNeeded },
                state.flatMapLatest {
                    $0.shouldQueryMoreMyInterestedMedia
                        ? presenter.collectionView.rx.triggerGetMore
                        : .empty()
                    }.map { .onTriggerGetMoreMyInterestedMedia },
                presenter.refreshControl.rx.controlEvent(.valueChanged).asSignal().map { .onTriggerReloadMyInterestedMedia },
                presenter.fabButton.rx.tap.asSignal().flatMapLatest { PhotoPickerProvider.pickImages(from: weakSelf, imageLimit: 20) } .map(HomeStateObject.Event.onTriggerCreateImage),
                presenter.addUserButton.rx.tap.asSignal().map { .onTriggerSearchUser },
                ]
            return Bindings(subscriptions: subscriptions, events: events)
        }
        
        let queryMyInterestedMedia: Feedback = react(query: { $0.myInterestedMediaQuery }, effects: composeEffects(shouldQuery: { [weak self] in self?.shouldReactQuery ?? false  }) { query in
            ApolloClient.shared.rx.fetch(query: query, cachePolicy: .fetchIgnoringCacheData)
                .map { $0?.data?.user?.interestedMedia.fragments.cursorMediaFragment }.unwrap()
                .map(HomeStateObject.Event.onGetMyInterestedMedia(isReload: query.cursor == nil))
                .asSignal(onErrorReturnJust: HomeStateObject.Event.onGetMyInterestedMediaError)
        })
        
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
        return LoadFooterViewState.create(
            cursor: myInterestedMedia?.cursor.value,
            items: myInterestedMedia?.items,
            trigger: triggerMyInterestedMediaQuery,
            error: myInterestedMediaError
        )
    }
}

