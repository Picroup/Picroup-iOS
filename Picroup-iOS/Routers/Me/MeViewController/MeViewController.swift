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

class MeViewController: UIViewController {
    
    fileprivate typealias Feedback = DriverFeedback<MeState>
    @IBOutlet fileprivate var presenter: MePresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRxFeedback()
    }
    
    private func setupRxFeedback() {
        
        let injectDependncy = self.injectDependncy(store: store)
        let uiFeedback = self.uiFeedback
        let queryMe = Feedback.queryMe(client: ApolloClient.shared)
        let queryMyMedia = Feedback.queryMyMedia(client: ApolloClient.shared)
        let queryMySatredMedia = Feedback.queryMySatredMedia(client: ApolloClient.shared)
        let showImageDetail = Feedback.showImageDetail(from: self)
        let showReputations = Feedback.showReputations(from: self)
        let triggerReloadMe = Feedback.triggerReloadMe(from: self)
        let pop = Feedback.pop(from: self)

        let reduce = logger(identifier: "MeState")(MeState.reduce)
        
        Driver<Any>.system(
            initialState: MeState.empty(),
            reduce: reduce,
            feedback:
                injectDependncy,
                uiFeedback,
                queryMe,
                queryMyMedia,
                queryMySatredMedia,
                showImageDetail,
                showReputations,
                triggerReloadMe,
                pop
            )
            .drive()
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

extension MeViewController {
    
    fileprivate func injectDependncy(store: Store) -> Feedback.Raw {
        return { _ in
            store.state.map { $0.currentUser?.toUser() }.asSignal(onErrorJustReturn: nil).map { .onUpdateCurrentUser($0) }
        }
    }
    
    fileprivate var uiFeedback: Feedback.Raw {
        typealias Section = MePresenter.Section
        return bind(presenter) { (presenter, state) -> Bindings<MeState.Event> in
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
                state.map { $0.selectedTab }.distinctUntilChanged().drive(presenter.selectedTab),
                state.map { [Section(model: "", items: $0.myMediaItems)] }.drive(presenter.myMediaItems),
                state.map { [Section(model: "", items: $0.myStaredMediaItems)] }.drive(presenter.myStaredMediaItems),
            ]
            
            let events: [Signal<MeState.Event>] = [
                presenter.myMediaButton.rx.tap.asSignal().map { .onChangeSelectedTab(.myMedia) },
                presenter.myStaredMediaButton.rx.tap.asSignal().map { .onChangeSelectedTab(.myStaredMedia) },
                state.flatMapLatest {
                    $0.shouldQueryMoreMyMedia ? presenter.myMediaCollectionView.rx.isNearBottom.asSignal() : .empty()
                    }.map { .onTriggerGetMoreMyMedia },
                presenter.myMediaCollectionView.rx.itemSelected.asSignal().map { .onTriggerShowImageDetail($0.item) },
                presenter.myStardMediaCollectionView.rx.itemSelected.asSignal().map { .onTriggerShowImageDetail($0.item) },
                presenter.reputationButton.rx.tap.asSignal().map { _ in .onTriggerShowReputations },
                presenter.meBackgroundView.rx.tapGesture().when(.recognized).asSignalOnErrorRecoverEmpty().map { _ in .onPop }
                ]
            return Bindings(subscriptions: subscriptions, events: events)

        }
    }
}


