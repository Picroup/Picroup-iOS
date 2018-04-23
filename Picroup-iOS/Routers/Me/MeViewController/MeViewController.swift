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
        
        let reduce = logger(identifier: "MeState")(MeState.reduce)
        
        Driver<Any>.system(
            initialState: MeState.empty(userId: Config.userId),
            reduce: reduce,
            feedback:
                uiFeedback,
                queryMe,
                queryMyMedia,
                showImageDetail
            )
            .drive()
            .disposed(by: disposeBag)
    }
}

extension MeViewController {
    
    fileprivate var uiFeedback: Feedback.Raw {
        typealias Section = MePresenter.Section
        return bind(presenter) { (presenter, state) -> Bindings<MeState.Event> in
            let subscriptions: [Disposable] = [
                state.map { $0.me.data?.username }.drive(presenter.usernameLabel.rx.text),
                state.map { $0.me.data?.reputation.description }.drive(presenter.reputationCountLabel.rx.text),
                state.map { $0.me.data?.followersCount.description }.drive(presenter.followersCountLabel.rx.text),
                state.map { $0.me.data?.followingsCount.description }.drive(presenter.followingsCountLabel.rx.text),
                state.map { [Section(model: "", items: $0.myMediaItems)] }.drive(presenter.items),
            ]
            let events: [Signal<MeState.Event>] = [
                state.flatMapLatest {
                    $0.shouldQueryMoreMyMedia ? presenter.collectionView.rx.isNearBottom.asSignal() : .empty()
                    }.map { .onTriggerGetMore },
                presenter.collectionView.rx.itemSelected.asSignal().map { .onTriggerShowImageDetail($0.item) }
                ]
            return Bindings(subscriptions: subscriptions, events: events)

        }
    }
}


