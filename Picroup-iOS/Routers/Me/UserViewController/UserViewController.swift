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
                store.userMediaItems().map { [Section(model: "", items: $0)] }.drive(presenter.myMediaItems),
                ]
            let events: [Signal<UserStateObject.Event>] = [
                state.flatMapLatest {
                    $0.shouldQueryMoreUserMedia
                        ? presenter.myMediaCollectionView.rx.triggerGetMore
                        : .empty()
                    }.map { .onTriggerGetMoreUserMedia },
                presenter.myMediaCollectionView.rx.modelSelected(MediumObject.self).asSignal().map { .onTriggerShowImage($0._id) },
                presenter.meBackgroundView.rx.tapGesture().when(.recognized).asSignalOnErrorRecoverEmpty().map { _ in .onTriggerPop },
                    .of(.onTriggerReloadUser, .onTriggerReloadUserMedia),
                ]
            return Bindings(subscriptions: subscriptions, events: events)
            
        }
        
        let queryUser: Feedback = react(query: { $0.userQuery }) { query in
            ApolloClient.shared.rx.fetch(query: query, cachePolicy: .fetchIgnoringCacheData)
                .map { $0?.data?.user?.fragments.userDetailFragment }.unwrap()
                .map(UserStateObject.Event.onGetUserSuccess)
                .asSignal(onErrorReturnJust: UserStateObject.Event.onGetUserError)
        }
        
        let queryUserMedia: Feedback = react(query: { $0.userMediaQuery }) { query in
            ApolloClient.shared.rx.fetch(query: query, cachePolicy: .fetchIgnoringCacheData)
                .map { $0?.data?.user?.media.fragments.cursorMediaFragment }.unwrap()
                .map(UserStateObject.Event.onGetUserMedia(isReload: query.cursor == nil))
                .asSignal(onErrorReturnJust: UserStateObject.Event.onGetUserMediaError)
        }
        
        let states = store.states
        
        Signal.merge(
            uiFeedback(states),
            queryUser(states),
            queryUserMedia(states)
            )
            .debug("UserStateObject.Event", trimOutput: true)
            .emit(onNext: store.on)
            .disposed(by: disposeBag)

//        let injectDependncy = self.injectDependncy(appStore: appStore)
//        let uiFeedback = self.uiFeedback
//        let queryUser = Feedback.queryUser(client: ApolloClient.shared)
//        let queryMyMedia = Feedback.queryMyMedia(client: ApolloClient.shared)
////        let showImageDetail = Feedback.showImageDetail(from: self)
//        let pop = Feedback.pop(from: self)
//
//        let reduce = logger(identifier: "UserState")(UserState.reduce)
//
//        Driver<Any>.system(
//            initialState: UserState.empty(userId: userId),
//            reduce: reduce,
//            feedback:
//                injectDependncy,
//                uiFeedback,
//                queryUser,
//                queryMyMedia,
////                showImageDetail,
//                pop
//            )
//            .drive()
//            .disposed(by: disposeBag)
        
        presenter.myMediaCollectionView.rx.shouldHideNavigationBar()
            .emit(onNext: { [weak presenter, weak self] in
                presenter?.hideDetailLayoutConstraint.isActive = $0
                UIView.animate(withDuration: 0.3) { self?.view.layoutIfNeeded() }
            })
            .disposed(by: disposeBag)

    }
}
extension UserViewController {
    
//    fileprivate func injectDependncy(appStore: AppStore) -> Feedback.Raw {
//        return { _ in
//            appStore.state.map { $0.currentUser?.toUser() }.asSignal(onErrorJustReturn: nil).map { .onUpdateCurrentUser($0) }
//        }
//    }
    
//    fileprivate var uiFeedback: Feedback.Raw {
//        typealias Section = UserPresenter.Section
//        return bind(presenter) { (presenter, state) -> Bindings<UserState.Event> in
//            let meViewModel = state.map { UserViewModel(user: $0.user) }
//            let subscriptions: [Disposable] = [
//                meViewModel.map { $0.avatarId }.drive(presenter.userAvatarImageView.rx.imageMinioId),
//                meViewModel.map { $0.username }.drive(presenter.displaynameLabel.rx.text),
//                meViewModel.map { $0.username }.drive(presenter.usernameLabel.rx.text),
//                meViewModel.map { $0.reputation }.drive(presenter.reputationCountLabel.rx.text),
//                meViewModel.map { $0.followersCount }.drive(presenter.followersCountLabel.rx.text),
//                meViewModel.map { $0.followingsCount }.drive(presenter.followingsCountLabel.rx.text),
//                state.map { [Section(model: "", items: $0.myMediaItems)] }.drive(presenter.myMediaItems),
//                ]
//            let events: [Signal<UserState.Event>] = [
//                state.flatMapLatest {
//                    $0.shouldQueryMoreMyMedia ? presenter.myMediaCollectionView.rx.isNearBottom.asSignal() : .empty()
//                    }.map { .onTriggerGetMoreMyMedia },
//                presenter.myMediaCollectionView.rx.itemSelected.asSignal().map { .onTriggerShowImageDetail($0.item) },
//                presenter.meBackgroundView.rx.tapGesture().when(.recognized).asSignalOnErrorRecoverEmpty().map { _ in .onPop }
//                ]
//            return Bindings(subscriptions: subscriptions, events: events)
//
//        }
//    }
}
