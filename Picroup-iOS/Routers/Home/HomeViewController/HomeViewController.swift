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
        presenter.setup(navigationItem: navigationItem)
        setupRxFeedback()
    }
    
    private func setupRxFeedback() {

        guard let store = try? HomeStateStore() else { return }
        
        typealias Section = MediaPreserter.Section

        weak var weakSelf = self
        let uiFeedback: Feedback = bind(self) { (me, state) in
            let presenter = me.presenter!
//            let _events = PublishRelay<HomeStateObject.Event>()
            let footerState = BehaviorRelay<LoadFooterViewState>(value: .empty)
            let subscriptions = [
                store.myInterestedMediaItems().map { [Section(model: "", items: $0)] }.drive(presenter.mediaPresenter.items(footerState: footerState.asDriver())),
                state.map { $0.myInterestedMediaState?.isReload ?? false }.drive(presenter.refreshControl.rx.isRefreshing),
                state.map { $0.myInterestedMediaState?.footerState ?? .empty }.drive(footerState),
                state.map { $0.myInterestedMediaState?.isEmpty ??  false }.drive(presenter.isMyInterestedMediaEmpty),
                presenter.fabButton.rx.tap.asSignal().map { false }.emit(to: me.rx.setNavigationBarHidden(animated: true)),
                presenter.collectionView.rx.shouldHideNavigationBar().emit(to: me.rx.setNavigationBarHidden(animated: true)),
                presenter.collectionView.rx.shouldHideNavigationBar().emit(to: me.rx.setTabBarHidden(animated: true)),
                presenter.collectionView.rx.shouldHideNavigationBar().emit(to: presenter.isFabButtonHidden),
                ]
            let events: [Signal<HomeStateObject.Event>] = [
                .just(.myInterestedMediaState(.onTriggerReload)),
//                _events.asSignal(),
                me.rx.viewWillAppear.asSignal().map { _ in .onTriggerReloadMyInterestedMediaIfNeeded },
                state.flatMapLatest {
                    ($0.myInterestedMediaState?.shouldQueryMore ?? false)
                        ? presenter.collectionView.rx.triggerGetMore
                        : .empty()
                    }.map { .myInterestedMediaState(.onTriggerGetMore) },
                presenter.collectionView.rx.modelSelected(MediumObject.self).asSignal().map { .onTriggerShowImage($0._id) },
                presenter.refreshControl.rx.controlEvent(.valueChanged).asSignal().map { .myInterestedMediaState(.onTriggerReload) },
                presenter.fabButton.rx.tap.asSignal().flatMapLatest { PhotoPickerProvider.pickMedia(from: weakSelf) } .map(HomeStateObject.Event.onTriggerCreateImage),
                presenter.addUserButton.rx.tap.asSignal().map { .onTriggerSearchUser },
                ]
            return Bindings(subscriptions: subscriptions, events: events)
        }
        
        let queryMyInterestedMedia: Feedback = react(query: { $0.myInterestedMediaQuery }, effects: composeEffects(shouldQuery: { [weak self] in self?.shouldReactQuery ?? false  }) { query in
            ApolloClient.shared.rx.fetch(query: query, cachePolicy: .fetchIgnoringCacheData)
                .map { $0?.data?.user?.interestedMedia.fragments.cursorMediaFragment }.unwrap()
                .map { .myInterestedMediaState(.onGetData($0)) }
                .asSignal(onErrorReturnJust: { .myInterestedMediaState(.onGetError($0)) })
        })
        
        let states = store.states
//            .debug("HomeState")
        
        Signal.merge(
            uiFeedback(states),
            queryMyInterestedMedia(states)
            )
            .debug("HomeState.Event", trimOutput: true)
            .emit(onNext: store.on)
            .disposed(by: disposeBag)
        
        presenter.collectionView.rx.setDelegate(presenter.mediaPresenter).disposed(by: disposeBag)
    }
}
