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
import RealmSwift

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

final class UserViewController: ShowNavigationBarViewController, IsStateViewController {
    
    typealias State = UserStateObject
    typealias Event = State.Event

    typealias Dependency = String
    var dependency: String!
    
    @IBOutlet fileprivate var presenter: UserPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.setup(navigationItem: navigationItem)
        setupRxFeedback()
    }
    
    private func setupRxFeedback() {
        
        guard let userId = dependency,
            let realm = try? Realm(),
            let state = try? State.create(userId: userId)(realm) else { return }
        
        state.system(
            uiFeedback: uiFeedback,
            shouldQuery: { [weak self] in self?.shouldReactQuery ?? false  },
            queryUser: { query in
                return ApolloClient.shared.rx.fetch(query: query, cachePolicy: .fetchIgnoringCacheData)
                    .map { $0?.data?.user }.forceUnwrap()
        },
            queryUserMedia: { query in
                return ApolloClient.shared.rx.fetch(query: query, cachePolicy: .fetchIgnoringCacheData)
                    .map { ($0?.data?.user?.media.snapshot).map(CursorMediaFragment.init(snapshot: )) }.forceUnwrap()
        },
            followUser: { query in
                return ApolloClient.shared.rx.perform(mutation: query)
                    .map { $0?.data?.followUser }.forceUnwrap()
        },
            unfollowUser: { query in
                return ApolloClient.shared.rx.perform(mutation: query)
                    .map { $0?.data?.unfollowUser }.forceUnwrap()
        },
            blockUser: { query in
                return ApolloClient.shared.rx.perform(mutation: query)
                    .map { $0?.data?.blockUser }.forceUnwrap()
        },
            starMedium: { query in
                return ApolloClient.shared.rx.perform(mutation: query)
                    .map { $0?.data?.starMedium }.forceUnwrap()
        })
            .drive()
            .disposed(by: disposeBag)

    }
    
    var uiFeedback: State.DriverFeedback {
        weak var weakSelf = self
        return bind(self) { (me, state) -> Bindings<Event> in
            typealias Section = MediaPreserter.Section
            let _events = PublishRelay<Event>()
            let presenter = me.presenter!
            let myMediaFooterState = BehaviorRelay<LoadFooterViewState>(value: .empty)
            let subscriptions: [Disposable] = [
                state.map { $0.userQueryState?.user }.drive(presenter.user),
                state.map { [Section(model: "", items: $0.userMediaItems())] }.drive(presenter.myMediaPresenter.items(
                    footerState: myMediaFooterState.asDriver(),
                    onStarButtonTap: { _events.accept(.onTriggerStarMedium($0)) }
                )),
                state.map { $0.userMediaQueryState?.footerState ?? .empty }.drive(myMediaFooterState),
                state.map { $0.userMediaQueryState?.isEmpty ?? false }.drive(presenter.isUserMediaEmpty),
                presenter.myMediaCollectionView.rx.shouldHideNavigationBar().emit(onNext: {
                    weakSelf?.presenter?.hideDetailLayoutConstraint.isActive = $0
                    UIView.animate(withDuration: 0.3) { weakSelf?.view.layoutIfNeeded() }
                }),
                presenter.myMediaCollectionView.rx.setDelegate(presenter.myMediaPresenter),
                ]
            let events: [Signal<Event>] = [
                .of(.onTriggerReloadUser, .onTriggerReloadUserMedia),
                _events.asSignal(),
                presenter.moreButton.rx.tap.asSignal().withLatestFrom(state).flatMapLatest(mapMoreButtonTapToEvent(sender: presenter.moreButton)),
                state.flatMapLatest {
                    ($0.userMediaQueryState?.shouldQueryMore ?? false)
                        ? presenter.myMediaCollectionView.rx.triggerGetMore
                        : .empty()
                    }.map { .onTriggerGetMoreUserMedia },
                presenter.followButton.rx.tap.asSignal()
                    .withLatestFrom(state)
                    .flatMapLatest { state in
                        switch state.userQueryState?.user?.followed.value {
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
    }
}

extension UserStateObject {
    
    func userMediaItems() -> [MediumObject] {
        return userMediaQueryState?.cursorMedia?.items.toArray() ?? []
    }
}

