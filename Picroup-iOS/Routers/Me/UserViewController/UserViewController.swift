//
//  UserViewController.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/10.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import Apollo
import RxSwift
import RxCocoa
import RxGesture
import RxFeedback

class UserViewController: HideNavigationBarViewController {

    typealias Dependency = String
    var dependency: String!
    
    fileprivate typealias Feedback = DriverFeedback<UserState>
    @IBOutlet fileprivate var presenter: UserPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRxFeedback()
    }
    
    private func setupRxFeedback() {
        
        guard let userId = dependency else { return }
        
        let injectDependncy = self.injectDependncy(store: store)
        let uiFeedback = self.uiFeedback
        let queryUser = Feedback.queryUser(client: ApolloClient.shared)
        let queryMyMedia = Feedback.queryMyMedia(client: ApolloClient.shared)
        let showImageDetail = Feedback.showImageDetail(from: self)
        let pop = Feedback.pop(from: self)

        let reduce = logger(identifier: "UserState")(UserState.reduce)

        Driver<Any>.system(
            initialState: UserState.empty(userId: userId),
            reduce: reduce,
            feedback:
                injectDependncy,
                uiFeedback,
                queryUser,
                queryMyMedia,
                showImageDetail,
                pop
            )
            .drive()
            .disposed(by: disposeBag)
        
        presenter.myMediaCollectionView.rx.shouldHideNavigationBar()
            .emit(onNext: { [weak presenter, weak self] in
                presenter?.hideDetailLayoutConstraint.isActive = $0
                UIView.animate(withDuration: 0.3) { self?.view.layoutIfNeeded() }
            })
            .disposed(by: disposeBag)

    }
}
extension UserViewController {
    
    fileprivate func injectDependncy(store: Store) -> Feedback.Raw {
        return { _ in
            store.state.map { $0.currentUser?.toUser() }.asSignal(onErrorJustReturn: nil).map { .onUpdateCurrentUser($0) }
        }
    }
    
    fileprivate var uiFeedback: Feedback.Raw {
        typealias Section = UserPresenter.Section
        return bind(presenter) { (presenter, state) -> Bindings<UserState.Event> in
            let meViewModel = state.map { UserViewModel(user: $0.user) }
            let subscriptions: [Disposable] = [
                meViewModel.map { $0.avatarId }.drive(presenter.userAvatarImageView.rx.imageMinioId),
                meViewModel.map { $0.username }.drive(presenter.displaynameLabel.rx.text),
                meViewModel.map { $0.username }.drive(presenter.usernameLabel.rx.text),
                meViewModel.map { $0.reputation }.drive(presenter.reputationCountLabel.rx.text),
                meViewModel.map { $0.followersCount }.drive(presenter.followersCountLabel.rx.text),
                meViewModel.map { $0.followingsCount }.drive(presenter.followingsCountLabel.rx.text),
                state.map { [Section(model: "", items: $0.myMediaItems)] }.drive(presenter.myMediaItems),
                ]
            let events: [Signal<UserState.Event>] = [
                state.flatMapLatest {
                    $0.shouldQueryMoreMyMedia ? presenter.myMediaCollectionView.rx.isNearBottom.asSignal() : .empty()
                    }.map { .onTriggerGetMoreMyMedia },
                presenter.myMediaCollectionView.rx.itemSelected.asSignal().map { .onTriggerShowImageDetail($0.item) },
                presenter.meBackgroundView.rx.tapGesture().when(.recognized).asSignalOnErrorRecoverEmpty().map { _ in .onPop }
                ]
            return Bindings(subscriptions: subscriptions, events: events)
            
        }
    }
}
