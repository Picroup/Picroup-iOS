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

private func mapMoreButtonTapToEvent(sender: UIView) -> (UserStateObject) -> Signal<UserStateObject.Event> {
    return { state in
        guard state.sessionState?.isLogin == true else {
            return .just(.onTriggerLogin)
        }
        return DefaultWireframe.shared
            .promptFor(sender: sender, cancelAction: "取消", actions: ["举报", "拉黑"])
            .asSignalOnErrorRecoverEmpty()
            .flatMap { action in
                switch action {
                case "举报":     return .just(.onTriggerUserFeedback)
                case "拉黑":     return confirmBlockUser()
                default:        return .empty()
                }
        }
    }
}

private func confirmBlockUser() -> Signal<UserStateObject.Event> {
    return DefaultWireframe.shared
        .promptFor(message: "您将屏蔽对方发布的内容，您确定要拉黑吗？", preferredStyle: .alert, sender: nil, cancelAction: "取消", actions: ["拉黑"])
        .asSignalOnErrorRecoverEmpty()
        .flatMap { action in
            switch action {
            case "拉黑":     return .just(.onTriggerBlockUser)
            default:        return .empty()
            }
    }
}

class UserViewController: ShowNavigationBarViewController {

    typealias Dependency = String
    var dependency: String!
    
    fileprivate typealias Feedback = (Driver<UserStateObject>) -> Signal<UserStateObject.Event>
    @IBOutlet fileprivate var presenter: UserPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.setup(navigationItem: navigationItem)
        setupRxFeedback()
    }
    
    private func setupRxFeedback() {
        
        guard
            let userId = dependency,
            let store = try? UserStateStore(userId: userId) else {
                return
        }
        
        typealias Section = MediaPreserter.Section

        let uiFeedback: Feedback = bind(presenter) { (presenter, state) -> Bindings<UserStateObject.Event> in
            let myMediaFooterState = BehaviorRelay<LoadFooterViewState>(value: .empty)
            let subscriptions: [Disposable] = [
                state.map { $0.user }.drive(presenter.user),
                store.userMediaItems().map { [Section(model: "", items: $0)] }.drive(presenter.myMediaPresenter.items(footerState: myMediaFooterState.asDriver())),
                state.map { $0.userMediaState?.footerState ?? .empty }.drive(myMediaFooterState),
                state.map { $0.userMediaState?.isEmpty ?? false }.drive(presenter.isUserMediaEmpty),
                ]
            let events: [Signal<UserStateObject.Event>] = [
                .of(.onTriggerReloadUser, .userMediaState(.onTriggerReload)),
                presenter.moreButton.rx.tap.asSignal().withLatestFrom(state).flatMapLatest(mapMoreButtonTapToEvent(sender: presenter.moreButton)),
                state.flatMapLatest {
                    ($0.userMediaState?.shouldQueryMore ?? false)
                        ? presenter.myMediaCollectionView.rx.triggerGetMore
                        : .empty()
                    }.map { .userMediaState(.onTriggerGetMore) },
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
        
        let queryUser: Feedback = react(query: { $0.userQuery }, effects: composeEffects(shouldQuery: { [weak self] in self?.shouldReactQuery ?? false  }) { query in
            ApolloClient.shared.rx.fetch(query: query, cachePolicy: .fetchIgnoringCacheData)
                .map { $0?.data?.user }.unwrap()
                .map(UserStateObject.Event.onGetUserSuccess)
                .asSignal(onErrorReturnJust: UserStateObject.Event.onGetUserError)
        })
        
        let queryUserMedia: Feedback = react(query: { $0.userMediaQuery }, effects: composeEffects(shouldQuery: { [weak self] in self?.shouldReactQuery ?? false  }) { query in
            ApolloClient.shared.rx.fetch(query: query, cachePolicy: .fetchIgnoringCacheData)
                .map { $0?.data?.user?.media.fragments.cursorMediaFragment }.unwrap()
                .map { .userMediaState(.onGetData($0)) }
                .asSignal(onErrorReturnJust: { .userMediaState(.onGetError($0)) })
        })
        
        let followUser: Feedback = react(query: { $0.followUserQuery }, effects: composeEffects(shouldQuery: { [weak self] in self?.shouldReactQuery ?? false  }) { query in
            ApolloClient.shared.rx.perform(mutation: query).asObservable()
                .map { $0?.data?.followUser }.unwrap()
                .map(UserStateObject.Event.onFollowUserSuccess)
                .asSignal(onErrorReturnJust: UserStateObject.Event.onFollowUserError)
        })
        
        let unfollowUser: Feedback = react(query: { $0.unfollowUserQuery }, effects: composeEffects(shouldQuery: { [weak self] in self?.shouldReactQuery ?? false  }) { query in
            ApolloClient.shared.rx.perform(mutation: query).asObservable()
                .map { $0?.data?.unfollowUser }.unwrap()
                .map(UserStateObject.Event.onUnfollowUserSuccess)
                .asSignal(onErrorReturnJust: UserStateObject.Event.onUnfollowUserError)
        })
        
        let blockUser: Feedback = react(query: { $0.blockUserQuery }, effects: composeEffects(shouldQuery: { [weak self] in self?.shouldReactQuery ?? false  }) { query in
            ApolloClient.shared.rx.perform(mutation: query).asObservable()
                .map { $0?.data?.blockUser.fragments.userFragment }.unwrap()
                .map(UserStateObject.Event.onBlockUserSuccess)
                .asSignal(onErrorReturnJust: UserStateObject.Event.onBlockUserError)
        })
        
        let states = store.states
        
        Signal.merge(
            uiFeedback(states),
            queryUser(states),
            queryUserMedia(states),
            followUser(states),
            unfollowUser(states),
            blockUser(states)
            )
            .debug("UserState.Event", trimOutput: true)
            .emit(onNext: store.on)
            .disposed(by: disposeBag)

        presenter.myMediaCollectionView.rx.shouldHideNavigationBar()
            .emit(onNext: { [weak presenter, weak self] in
                presenter?.hideDetailLayoutConstraint.isActive = $0
                UIView.animate(withDuration: 0.3) { self?.view.layoutIfNeeded() }
            })
            .disposed(by: disposeBag)

        presenter.myMediaCollectionView.rx.setDelegate(presenter.myMediaPresenter).disposed(by: disposeBag)
    }
}

