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
        
        let uiFeedback = self.uiFeedback
        let queryMe = Feedback.queryMe(client: ApolloClient.shared)
        let queryMyMedia = Feedback.queryMyMedia(client: ApolloClient.shared)
        let showImageDetail = Feedback.showImageDetail(from: self)
        let showReputations = Feedback.showReputations(from: self)
        let triggerReloadMe = Feedback.triggerReloadMe(from: self)
        
        let reduce = logger(identifier: "MeState")(MeState.reduce)
        
        Driver<Any>.system(
            initialState: MeState.empty(userId: Config.userId),
            reduce: reduce,
            feedback:
                uiFeedback,
                queryMe,
                queryMyMedia,
                showImageDetail,
                showReputations,
                triggerReloadMe
            )
            .drive()
            .disposed(by: disposeBag)
        
        presenter.collectionView.rx.shouldHideNavigationBar()
            .emit(onNext: { [weak presenter, weak self] in
                presenter?.hideDetailLayoutConstraint.isActive = $0
                presenter?.showDetailLayoutConstraint.isActive = !$0
                UIView.animate(withDuration: 0.3) { self?.tabBarController?.view.layoutIfNeeded() }
            })
            .disposed(by: disposeBag)

    }
}

extension MeViewController {
    
    fileprivate var uiFeedback: Feedback.Raw {
        typealias Section = MePresenter.Section
        return bind(presenter) { (presenter, state) -> Bindings<MeState.Event> in
            let meViewModel = state.map { UserViewModel(user: $0.me) }
            let subscriptions: [Disposable] = [
                meViewModel.map { $0.username }.drive(presenter.usernameLabel.rx.text),
                meViewModel.map { $0.reputation }.drive(presenter.reputationCountLabel.rx.text),
                meViewModel.map { $0.followersCount }.drive(presenter.followersCountLabel.rx.text),
                meViewModel.map { $0.followingsCount }.drive(presenter.followingsCountLabel.rx.text),
                meViewModel.map { $0.gainedReputationCount }.drive(presenter.gainedReputationCountButton.rx.title()),
                meViewModel.map { $0.isGainedReputationCountHidden }.drive(presenter.gainedReputationCountButton.rx.isHidden),
                state.map { [Section(model: "", items: $0.myMediaItems)] }.drive(presenter.items),
            ]
            let events: [Signal<MeState.Event>] = [
                state.flatMapLatest {
                    $0.shouldQueryMoreMyMedia ? presenter.collectionView.rx.isNearBottom.asSignal() : .empty()
                    }.map { .onTriggerGetMore },
                presenter.collectionView.rx.itemSelected.asSignal().map { .onTriggerShowImageDetail($0.item) },
                presenter.reputationView.rx.tapGesture().when(.recognized).asSignalOnErrorRecoverEmpty().map { _ in .onTriggerShowReputations },
                ]
            return Bindings(subscriptions: subscriptions, events: events)

        }
    }
}


