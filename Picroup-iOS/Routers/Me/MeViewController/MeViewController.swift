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
import Material

private func mapMoreButtonTapToEvent(sender: UIView) -> (MeStateObject) -> Signal<MeStateObject.Event> {
    return { state in
        guard state.session?.isLogin == true else { return .empty() }
        return DefaultWireframe.shared
            .promptFor(sender: sender, cancelAction: "取消", actions: ["更新个人信息", "应用反馈", "黑名单", "关于应用", "退出登录"])
            .asSignalOnErrorRecoverEmpty()
            .flatMap { action in
                switch action {
                case "更新个人信息":  return .just(.onTriggerUpdateUser)
                case "应用反馈":     return .just(.onTriggerAppFeedback)
                case "黑名单":      return .just(.onTriggerShowUserBlockings)
                case "关于应用":     return .just(.onTriggerAboutApp)
                case "退出登录":     return .just(.onLogout)
                default:            return .empty()
                }
        }
    }
}

class MeViewController: ShowNavigationBarViewController {
    
    fileprivate typealias Feedback = (Driver<MeStateObject>) -> Signal<MeStateObject.Event>
    @IBOutlet fileprivate var presenter: MePresenter! 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.setup(navigationItem: navigationItem)
        setupRxFeedback()
    }
    
    private func setupRxFeedback() {
        
        guard let store = try? MeStateStore(),
            let appStateService = appStateService,
            let appStore = appStateService.appStore
            else { return }
        
        typealias Section = MediaPreserter.Section

        let uiFeedback: Feedback = bind(self) { (me, state) in
            let presenter = me.presenter!
            let myMediaFooterState = BehaviorRelay<LoadFooterViewState>(value: .empty)
            let myStaredMediaFooterState = BehaviorRelay<LoadFooterViewState>(value: .empty)
            let subscriptions: [Disposable] = [
                appStore.me().drive(presenter.me),
                state.map { $0.selectedTabIndex }.distinctUntilChanged().drive(presenter.selectedTabIndex),
                store.myMediaItems().map { [Section(model: "", items: $0)] }.drive(presenter.myMediaPresenter.items(footerState: myMediaFooterState.asDriver())),
                store.myStaredMediaItems().map { [Section(model: "", items: $0)] }.drive(presenter.myStaredMediaPresenter.items(footerState: myStaredMediaFooterState.asDriver())),
                state.map { $0.myMediaState?.footerState ?? .empty }.drive(myMediaFooterState),
                state.map { $0.myStaredMediaState?.footerState ?? .empty }.drive(myStaredMediaFooterState),
                state.map { $0.myMediaState?.isEmpty ?? false }.drive(presenter.isMyMediaEmpty),
                state.map { $0.myStaredMediaState?.isEmpty ?? false }.drive(presenter.isMyStaredMediaEmpty),
                Signal.just(.onTriggerReloadMe).emit(to: appStateService.events),
                me.rx.viewWillAppear.asSignal().map { _ in .onTriggerReloadMe }.emit(to: appStateService.events),
                ]
            let events: [Signal<MeStateObject.Event>] = [
                .of(.myMediaState(.onTriggerReload), .myStaredMediaState(.onTriggerReload)),
                presenter.moreButton.rx.tap.asSignal().withLatestFrom(state).flatMapLatest(mapMoreButtonTapToEvent(sender: presenter.moreButton)),
                presenter.myMediaButton.rx.tap.asSignal().map { .onChangeSelectedTab(.myMedia) },
                presenter.myStaredMediaButton.rx.tap.asSignal().map { .onChangeSelectedTab(.myStaredMedia) },
                state.flatMapLatest {
                    ($0.myMediaState?.shouldQueryMore ?? false)
                        ? presenter.myMediaCollectionView.rx.triggerGetMore
                        : .empty()
                    }.map { .myMediaState(.onTriggerGetMore) },
                state.flatMapLatest {
                    ($0.myStaredMediaState?.shouldQueryMore ?? false)
                        ? presenter.myStaredMediaCollectionView.rx.triggerGetMore
                        : .empty()
                    }.map { .myStaredMediaState(.onTriggerGetMore) },
                me.rx.viewWillAppear.asSignal().map { _ in .onTriggerReloadMyMediaIfNeeded },
                me.rx.viewWillAppear.asSignal().map { _ in .onTriggerReloadMyStaredMediaIfNeeded },
                presenter.myMediaCollectionView.rx.modelSelected(MediumObject.self).asSignal().map { .onTriggerShowImage($0._id) },
                presenter.myStaredMediaCollectionView.rx.modelSelected(MediumObject.self).asSignal().map { .onTriggerShowImage($0._id) },
                presenter.reputationButton.rx.tap.asSignal().map { _ in .onTriggerShowReputations },
                presenter.followersButton.rx.tap.asSignal().map { _ in .onTriggerShowUserFollowers },
                presenter.followingsButton.rx.tap.asSignal().map { _ in .onTriggerShowUserFollowings },
                presenter.meBackgroundView.rx.tapGesture().when(.recognized).asSignalOnErrorRecoverEmpty().map { _ in .onTriggerPop },
                ]
            return Bindings(subscriptions: subscriptions, events: events)
        }
        
        let queryMyMedia: Feedback = react(query: { $0.myMediaQuery }, effects: composeEffects(shouldQuery: { [weak self] in self?.shouldReactQuery ?? false  }) { query in
            ApolloClient.shared.rx.fetch(query: query, cachePolicy: .fetchIgnoringCacheData)
                .map { $0?.data?.user?.media.fragments.cursorMediaFragment }.unwrap()
                .map { .myMediaState(.onGetData($0)) }
                .asSignal(onErrorReturnJust: { .myMediaState(.onGetError($0)) })
        })
        
        let queryMyStaredMedia: Feedback = react(query: { $0.myStaredMediaQuery }, effects: composeEffects(shouldQuery: { [weak self] in self?.shouldReactQuery ?? false  }) { query in
            ApolloClient.shared.rx.fetch(query: query, cachePolicy: .fetchIgnoringCacheData)
                .map { $0?.data?.user?.staredMedia.fragments.cursorMediaFragment }.unwrap()
                .map { .myStaredMediaState(.onGetData($0)) }
                .asSignal(onErrorReturnJust: { .myStaredMediaState(.onGetError($0)) })
        })
        
        let states = store.states
//            .debug("MeState", trimOutput: true)
        
        Signal.merge(
            uiFeedback(states),
            queryMyMedia(states),
            queryMyStaredMedia(states)
            )
            .debug("MeState.Event", trimOutput: true)
            .emit(onNext: store.on)
            .disposed(by: disposeBag)
        
        Signal.merge(
            presenter.myMediaCollectionView.rx.shouldHideNavigationBar(),
            presenter.myStaredMediaCollectionView.rx.shouldHideNavigationBar()
            )
            .emit(onNext: { [weak presenter, weak self] in
                presenter?.hideDetailLayoutConstraint.isActive = $0
                UIView.animate(withDuration: 0.3) { self?.view.layoutIfNeeded() }
            })
            .disposed(by: disposeBag)

        presenter.myMediaCollectionView.rx.setDelegate(presenter.myMediaPresenter).disposed(by: disposeBag)
        presenter.myStaredMediaCollectionView.rx.setDelegate(presenter.myStaredMediaPresenter).disposed(by: disposeBag)
    }
}
