//
//  MeViewController.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/10.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import Apollo
import RxSwift
import RxCocoa
import RxGesture
import RxFeedback
import RxViewController

class MeViewController: HideNavigationBarViewController {
    
    fileprivate typealias Feedback = (Driver<MeStateObject>) -> Signal<MeStateObject.Event>
    @IBOutlet fileprivate var presenter: MePresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRxFeedback()
    }
    
    private func setupRxFeedback() {
        
        guard let store = try? MeStateStore()  else { return }
        
        typealias Section = MePresenter.Section

        weak var me = self
        let uiFeedback: Feedback = bind(presenter) { (presenter, state) -> Bindings<MeStateObject.Event> in
            let meViewModel = state.map { UserViewModel(user: $0.me) }
            let subscriptions: [Disposable] = [
                meViewModel.map { $0.avatarId }.drive(presenter.userAvatarImageView.rx.imageMinioId),
                meViewModel.map { $0.username }.drive(presenter.displaynameLabel.rx.text),
                meViewModel.map { $0.username }.drive(presenter.usernameLabel.rx.text),
                meViewModel.map { $0.reputation }.drive(presenter.reputationCountLabel.rx.text),
                meViewModel.map { $0.followersCount }.drive(presenter.followersCountLabel.rx.text),
                meViewModel.map { $0.followingsCount }.drive(presenter.followingsCountLabel.rx.text),
                meViewModel.map { $0.gainedReputationCount }.drive(presenter.gainedReputationCountButton.rx.title()),
                meViewModel.map { $0.isGainedReputationCountHidden }.drive(presenter.gainedReputationCountButton.rx.isHidden),
                state.map { $0.selectedTabIndex }.distinctUntilChanged().drive(presenter.selectedTabIndex),
                store.myMediaItems().map { [Section(model: "", items: $0)] }.drive(presenter.myMediaItems),
                store.myStaredMediaItems().map { [Section(model: "", items: $0)] }.drive(presenter.myStaredMediaItems),
                ]
            
            let events: [Signal<MeStateObject.Event>] = [
                presenter.myMediaButton.rx.tap.asSignal().map { .onChangeSelectedTab(.myMedia) },
                presenter.myStaredMediaButton.rx.tap.asSignal().map { .onChangeSelectedTab(.myStaredMedia) },
                state.flatMapLatest {
                    $0.shouldQueryMoreMyMedia
                        ? presenter.myMediaCollectionView.rx.triggerGetMore
                        : .empty()
                    }.map { .onTriggerGetMoreMyMedia },
                state.flatMapLatest {
                    $0.shouldQueryMoreMyStaredMedia
                        ? presenter.myStardMediaCollectionView.rx.triggerGetMore
                        : .empty()
                    }.map { .onTriggerGetMoreMyStaredMedia },
                me?.rx.viewWillAppear.asSignal().map { _ in .onTriggerReloadMe } ?? .never(),
                presenter.myMediaCollectionView.rx.modelSelected(MediumObject.self).asSignal().map { .onTriggerShowImage($0._id) },
                presenter.myStardMediaCollectionView.rx.modelSelected(MediumObject.self).asSignal().map { .onTriggerShowImage($0._id) },
                presenter.reputationButton.rx.tap.asSignal().map { _ in .onTriggerShowReputations },
                presenter.followingsButton.rx.tap.asSignal().map { _ in .onTriggerShowUserFollowings },
                presenter.meBackgroundView.rx.tapGesture().when(.recognized).asSignalOnErrorRecoverEmpty().map { _ in .onTriggerPop },
                .of(.onTriggerReloadMe, .onTriggerReloadMyMedia, .onTriggerReloadMyStaredMedia),
                ]
            return Bindings(subscriptions: subscriptions, events: events)
        }
        
        let queryMe: Feedback = react(query: { $0.meQuery }) { query in
            ApolloClient.shared.rx.fetch(query: query, cachePolicy: .fetchIgnoringCacheData).map { $0?.data?.user?.fragments.userDetailFragment }.unwrap()
                .map(MeStateObject.Event.onGetMeSuccess)
                .asSignal(onErrorReturnJust: MeStateObject.Event.onGetMeError)
        }
        
        let queryMyMedia: Feedback = react(query: { $0.myMediaQuery }) { query in
            ApolloClient.shared.rx.fetch(query: query, cachePolicy: .fetchIgnoringCacheData)
                .map { $0?.data?.user?.media.fragments.cursorMediaFragment }.unwrap()
                .map(MeStateObject.Event.onGetMyMedia(isReload: query.cursor == nil))
                .asSignal(onErrorReturnJust: MeStateObject.Event.onGetMyMediaError)
        }
        
        let queryMyStaredMedia: Feedback = react(query: { $0.myStaredMediaQuery }) { query in
            ApolloClient.shared.rx.fetch(query: query, cachePolicy: .fetchIgnoringCacheData)
                .map { $0?.data?.user?.staredMedia.fragments.cursorMediaFragment }.unwrap()
                .map(MeStateObject.Event.onGetMyStaredMedia(isReload: query.cursor == nil))
                .asSignal(onErrorReturnJust: MeStateObject.Event.onGetMyStaredMediaError)
        }
        
        let states = store.states
        
        Signal.merge(
            uiFeedback(states),
            queryMe(states),
            queryMyMedia(states),
            queryMyStaredMedia(states)
            )
            .debug("MeStateObject.Event", trimOutput: true)
            .emit(onNext: store.on)
            .disposed(by: disposeBag)
        

        Signal.merge(
            presenter.myMediaCollectionView.rx.shouldHideNavigationBar(),
            presenter.myStardMediaCollectionView.rx.shouldHideNavigationBar()
            )
            .emit(onNext: { [weak presenter, weak self] in
                presenter?.hideDetailLayoutConstraint.isActive = $0
                UIView.animate(withDuration: 0.3) { self?.view.layoutIfNeeded() }
            })
            .disposed(by: disposeBag)

    }
}



