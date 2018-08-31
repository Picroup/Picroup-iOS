//
//  MyInterestedMediaViewController.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/9.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import Material
import RxSwift
import RxCocoa
import RxFeedback
import Apollo
import RealmSwift

final class HomeViewController: BaseViewController, IsStateViewController {
    
    typealias State = HomeStateObject
    typealias Event = State.Event

    @IBOutlet var presenter: HomeViewPresenter!

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.setup(navigationItem: navigationItem)
        setupRxFeedback()
    }
    
    private func setupRxFeedback() {
        
        guard let realm = try? Realm(), let state = try? State.create()(realm) else { return }
        
        state.system(
            uiFeedback: uiFeedback,
            shouldQuery: { [weak self] in self?.shouldReactQuery ?? false  },
            queryMyInterestedMedia: { query in
               return ApolloClient.shared.rx.fetch(query: query, cachePolicy: .fetchIgnoringCacheData)
                    .map { $0?.data?.user?.interestedMedia.fragments.cursorMediaFragment }.forceUnwrap()
        })
            .drive()
            .disposed(by: disposeBag)
    }
    
    var uiFeedback: State.DriverFeedback {
        typealias Section = MediaPreserter.Section
        weak var weakSelf = self
        return bind(self) { (me, state) in
            let presenter = me.presenter!
            //            let _events = PublishRelay<Event>()
            let footerState = BehaviorRelay<LoadFooterViewState>(value: .empty)
            let subscriptions = [
                state.map { [Section(model: "", items: $0.myInterestedMediaItems())] }.drive(presenter.mediaPresenter.items(footerState: footerState.asDriver())),
                state.map { $0.myInterestedMediaState?.isReload ?? false }.drive(presenter.refreshControl.rx.isRefreshing),
                state.map { $0.myInterestedMediaState?.footerState ?? .empty }.drive(footerState),
                state.map { $0.myInterestedMediaState?.isEmpty ??  false }.drive(presenter.isMyInterestedMediaEmpty),
                presenter.fabButton.rx.tap.asSignal().map { false }.emit(to: me.rx.setNavigationBarHidden(animated: true)),
                presenter.collectionView.rx.shouldHideNavigationBar().emit(to: me.rx.setNavigationBarHidden(animated: true)),
                presenter.collectionView.rx.shouldHideNavigationBar().emit(to: me.rx.setTabBarHidden(animated: true)),
                presenter.collectionView.rx.shouldHideNavigationBar().emit(to: presenter.isFabButtonHidden),
                presenter.collectionView.rx.setDelegate(presenter.mediaPresenter),
                ]
            let events: [Signal<Event>] = [
                .just(.onTriggerReloadMyInterestedMedia),
                //                _events.asSignal(),
                me.rx.viewWillAppear.asSignal().map { _ in .onTriggerReloadMyInterestedMediaIfNeeded },
                state.flatMapLatest {
                    ($0.myInterestedMediaState?.shouldQueryMore ?? false)
                        ? presenter.collectionView.rx.triggerGetMore
                        : .empty()
                    }.map { .onTriggerGetMoreMyInterestedMedia },
                presenter.collectionView.rx.modelSelected(MediumObject.self).asSignal().map { .onTriggerShowImage($0._id) },
                presenter.refreshControl.rx.controlEvent(.valueChanged).asSignal().map { .onTriggerReloadMyInterestedMedia },
                presenter.fabButton.rx.tap.asSignal().flatMapLatest { PhotoPickerProvider.pickMedia(from: weakSelf) } .map(Event.onTriggerCreateImage),
                presenter.addUserButton.rx.tap.asSignal().map { .onTriggerSearchUser },
                ]
            return Bindings(subscriptions: subscriptions, events: events)
        }
    }
}

extension HomeStateObject {

    fileprivate func myInterestedMediaItems() -> [MediumObject] {
        return myInterestedMediaState?.cursorMedia?.items.toArray() ?? []
    }
}
