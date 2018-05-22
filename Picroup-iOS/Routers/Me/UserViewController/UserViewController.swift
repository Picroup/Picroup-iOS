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
    
    fileprivate typealias Feedback = (Driver<UserStateObject>) -> Signal<UserStateObject.Event>
    @IBOutlet fileprivate var presenter: UserPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRxFeedback()
    }
    
    private func setupRxFeedback() {
        
        guard
            let userId = dependency,
            let store = try? UserStateStore(userId: userId) else {
                return
        }
        
        typealias Section = UserPresenter.Section
        
        let uiFeedback: Feedback = bind(presenter) { (presenter, state) -> Bindings<UserStateObject.Event> in
            let meViewModel = state.map { UserViewModel(user: $0.user) }
            let subscriptions: [Disposable] = [
                meViewModel.map { $0.avatarId }.drive(presenter.userAvatarImageView.rx.imageMinioId),
                meViewModel.map { $0.username }.drive(presenter.displaynameLabel.rx.text),
                meViewModel.map { $0.username }.drive(presenter.usernameLabel.rx.text),
                meViewModel.map { $0.reputation }.drive(presenter.reputationCountLabel.rx.text),
                meViewModel.map { $0.followersCount }.drive(presenter.followersCountLabel.rx.text),
                meViewModel.map { $0.followingsCount }.drive(presenter.followingsCountLabel.rx.text),
                meViewModel.map { $0.followed }.drive(StarButtonPresenter.isSelected(base: presenter.followButton)),
                store.userMediaItems().map { [Section(model: "", items: $0)] }.drive(presenter.myMediaItems),
                ]
            let events: [Signal<UserStateObject.Event>] = [
                .of(.onTriggerReloadUser, .onTriggerReloadUserMedia),
                state.flatMapLatest {
                    $0.shouldQueryMoreUserMedia
                        ? presenter.myMediaCollectionView.rx.triggerGetMore
                        : .empty()
                    }.map { .onTriggerGetMoreUserMedia },
                presenter.followButton.rx.tap.asSignal()
                    .withLatestFrom(state)
                    .flatMapLatest { state in
                        switch state.user?.followed.value {
                        case nil: return .empty()
                        case false?: return .just(.onTriggerFollowUser)
                        case true?: return .just(.onTriggerUnfollowUser)
                        }
                },
                presenter.myMediaCollectionView.rx.modelSelected(MediumObject.self).asSignal().map { .onTriggerShowImage($0._id) },
                presenter.followersButton.rx.tap.asSignal().map { _ in .onTriggerShowUserFollowers },
                presenter.followingsButton.rx.tap.asSignal().map { _ in .onTriggerShowUserFollowings },
                presenter.meBackgroundView.rx.tapGesture().when(.recognized).asSignalOnErrorRecoverEmpty().map { _ in .onTriggerPop },
                ]
            return Bindings(subscriptions: subscriptions, events: events)
            
        }
        
        let queryUser: Feedback = react(query: { $0.userQuery }) { query in
            ApolloClient.shared.rx.fetch(query: query, cachePolicy: .fetchIgnoringCacheData)
                .map { $0?.data?.user }.unwrap()
                .map(UserStateObject.Event.onGetUserSuccess)
                .asSignal(onErrorReturnJust: UserStateObject.Event.onGetUserError)
        }
        
        let queryUserMedia: Feedback = react(query: { $0.userMediaQuery }) { query in
            ApolloClient.shared.rx.fetch(query: query, cachePolicy: .fetchIgnoringCacheData)
                .map { $0?.data?.user?.media.fragments.cursorMediaFragment }.unwrap()
                .map(UserStateObject.Event.onGetUserMedia(isReload: query.cursor == nil))
                .asSignal(onErrorReturnJust: UserStateObject.Event.onGetUserMediaError)
        }
        
        let followUser: Feedback = react(query: { $0.followUserQuery }) { query in
            ApolloClient.shared.rx.perform(mutation: query).asObservable()
                .map { $0?.data?.followUser }.unwrap()
                .map(UserStateObject.Event.onFollowUserSuccess)
                .asSignal(onErrorReturnJust: UserStateObject.Event.onFollowUserError)
        }
        
        let unfollowUser: Feedback = react(query: { $0.unfollowUserQuery }) { query in
            ApolloClient.shared.rx.perform(mutation: query).asObservable()
                .map { $0?.data?.unfollowUser }.unwrap()
                .map(UserStateObject.Event.onUnfollowUserSuccess)
                .asSignal(onErrorReturnJust: UserStateObject.Event.onUnfollowUserError)
        }
        
        let states = store.states
        
        Signal.merge(
            uiFeedback(states),
            queryUser(states),
            queryUserMedia(states),
            followUser(states),
            unfollowUser(states)
            )
            .debug("UserStateObject.Event", trimOutput: true)
            .emit(onNext: store.on)
            .disposed(by: disposeBag)

        presenter.myMediaCollectionView.rx.shouldHideNavigationBar()
            .emit(onNext: { [weak presenter, weak self] in
                presenter?.hideDetailLayoutConstraint.isActive = $0
                UIView.animate(withDuration: 0.3) { self?.view.layoutIfNeeded() }
            })
            .disposed(by: disposeBag)

    }
}
