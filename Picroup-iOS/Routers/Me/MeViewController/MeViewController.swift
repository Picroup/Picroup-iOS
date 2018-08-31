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
import RealmSwift

private func mapMoreButtonTapToEvent(sender: UIView) -> (MeStateObject) -> Signal<MeStateObject.Event> {
    return { state in
        guard state.sessionState?.isLogin == true else { return .empty() }
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

class MeViewController: ShowNavigationBarViewController, IsStateViewController {
    
    typealias State = MeStateObject
    typealias Event = State.Event
    
    @IBOutlet fileprivate var presenter: MePresenter! 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.setup(navigationItem: navigationItem)
        setupRxFeedback()
    }
    
    private func setupRxFeedback() {
        
        guard let realm = try? Realm(),
            let state = try? State.create()(realm),
        let appStateService = appStateService,
        let appStore = appStateService.appStore else { return }
        
        state.system(
            uiFeedback: uiFeedback(appStateService: appStateService, appStore: appStore),
            shouldQuery: { [weak self] in self?.shouldReactQuery ?? false  },
            queryMyMedia: { query in
                return ApolloClient.shared.rx.fetch(query: query, cachePolicy: .fetchIgnoringCacheData)
                    .map { $0?.data?.user?.media.fragments.cursorMediaFragment }.forceUnwrap()
        },
            queryMyStaredMedia: { query in
                return ApolloClient.shared.rx.fetch(query: query, cachePolicy: .fetchIgnoringCacheData)
                    .map { $0?.data?.user?.staredMedia.fragments.cursorMediaFragment }.forceUnwrap()
        })
            .drive()
            .disposed(by: disposeBag)
    }
    
    func uiFeedback(appStateService: AppStateService, appStore: AppStateStore) -> State.DriverFeedback {
        typealias Section = MediaPreserter.Section
        weak var weakSelf = self
        return bind(self) { (me, state) in
            let presenter = me.presenter!
            let myMediaFooterState = BehaviorRelay<LoadFooterViewState>(value: .empty)
            let myStaredMediaFooterState = BehaviorRelay<LoadFooterViewState>(value: .empty)
            let subscriptions: [Disposable] = [
                appStore.me().drive(presenter.me),
                state.map { $0.tabState?.selectedIndex ?? 0 }.distinctUntilChanged().drive(presenter.selectedTabIndex),
                state.map { [Section(model: "", items: $0.myMediaItems())] }.drive(presenter.myMediaPresenter.items(footerState: myMediaFooterState.asDriver())),
                state.map { [Section(model: "", items: $0.myStaredMediaItems())] }.drive(presenter.myStaredMediaPresenter.items(footerState: myStaredMediaFooterState.asDriver())),
                state.map { $0.myMediaQueryState?.footerState ?? .empty }.drive(myMediaFooterState),
                state.map { $0.myStaredMediaQueryState?.footerState ?? .empty }.drive(myStaredMediaFooterState),
                state.map { $0.myMediaQueryState?.isEmpty ?? false }.drive(presenter.isMyMediaEmpty),
                state.map { $0.myStaredMediaQueryState?.isEmpty ?? false }.drive(presenter.isMyStaredMediaEmpty),
                Signal.just(.onTriggerReloadMe).emit(to: appStateService.events),
                me.rx.viewWillAppear.asSignal().map { _ in .onTriggerReloadMe }.emit(to: appStateService.events),
                Signal.merge(
                    presenter.myMediaCollectionView.rx.shouldHideNavigationBar(),
                    presenter.myStaredMediaCollectionView.rx.shouldHideNavigationBar()
                    )
                    .emit(onNext: {
                        weakSelf?.presenter?.hideDetailLayoutConstraint.isActive = $0
                        UIView.animate(withDuration: 0.3) { weakSelf?.view.layoutIfNeeded() }
                    }),
                presenter.myMediaCollectionView.rx.setDelegate(presenter.myMediaPresenter),
                presenter.myStaredMediaCollectionView.rx.setDelegate(presenter.myStaredMediaPresenter),
                ]
            let events: [Signal<Event>] = [
                .of(.onTriggerReloadMyMedia, .onTriggerReloadMyStaredMedia),
                presenter.moreButton.rx.tap.asSignal().withLatestFrom(state).flatMapLatest(mapMoreButtonTapToEvent(sender: presenter.moreButton)),
                presenter.myMediaButton.rx.tap.asSignal().map { .onChangeSelectedTab(.myMedia) },
                presenter.myStaredMediaButton.rx.tap.asSignal().map { .onChangeSelectedTab(.myStaredMedia) },
                state.flatMapLatest {
                    ($0.myMediaQueryState?.shouldQueryMore ?? false)
                        ? presenter.myMediaCollectionView.rx.triggerGetMore
                        : .empty()
                    }.map { .onTriggerGetMoreMyMedia },
                state.flatMapLatest {
                    ($0.myStaredMediaQueryState?.shouldQueryMore ?? false)
                        ? presenter.myStaredMediaCollectionView.rx.triggerGetMore
                        : .empty()
                    }.map { .onTriggerGetMoreMyStaredMedia },
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
    }
}

extension MeStateObject {
    func myMediaItems() -> [MediumObject] {
        return myMediaQueryState?.cursorMedia?.items.toArray() ?? []
    }
    
    func myStaredMediaItems() -> [MediumObject] {
        return myStaredMediaQueryState?.cursorMedia?.items.toArray() ?? []
    }
}
