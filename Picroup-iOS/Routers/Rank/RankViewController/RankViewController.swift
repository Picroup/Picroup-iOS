//
//  RankViewController.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/10.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import RxFeedback
import Material
import Apollo

class RankViewController: BaseViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    private var presenter: RankViewPresenter!
    
    private let disposeBag = DisposeBag()
    typealias Feedback = (Driver<RankStateObject>) -> Signal<RankStateObject.Event>
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = RankViewPresenter()
        presenter.setup(collectionView: collectionView, navigationItem: navigationItem)
        setupRxFeedback()
    }
    
    private func setupRxFeedback() {
        
        guard let store = try? RankStateStore() else { return }
        
        typealias Section = RankViewPresenter.Section
                
        let uiFeedback: Feedback = bind(presenter) { (presenter, state)  in
            let footerState = BehaviorRelay<LoadFooterViewState>(value: .empty)
            let subscriptions = [
//                store.rankMediaItems().map { [Section(model: "", items: $0)] }.drive(presenter.items(footerState.asDriver())),
                store.hotMediaItems().map { [Section(model: "", items: $0)] }.drive(presenter.items(footerState.asDriver())),
                state.map { $0.isReloadHotMedia }.drive(presenter.refreshControl.rx.refreshing),
                state.map { $0.footerState }.drive(footerState),
                state.map { $0.session?.isLogin ?? false }.drive(presenter.userButton.rx.isHidden),
            ]
            let events: [Signal<RankStateObject.Event>] = [
                state.flatMapLatest {
                    $0.shouldQueryMoreHotMedia
                        ? presenter.collectionView.rx.triggerGetMore
                        : .empty()
                }.map { .onTriggerGetMore },
                presenter.refreshControl.rx.controlEvent(.valueChanged).asSignal().map { .onTriggerReload },
                presenter.collectionView.rx.modelSelected(MediumObject.self).asSignal().map { .onTriggerShowImage($0._id) },
                presenter.userButton.rx.tap.asSignal().map { .onTriggerLogin },
            ]
            return Bindings(subscriptions: subscriptions, events: events)
        }
        
        let vcFeedback: Feedback = bind(self) { (me, state)  in
            let subscriptions = [
                me.collectionView.rx.shouldHideNavigationBar().emit(to: me.rx.setNavigationBarHidden(animated: true)),
                me.collectionView.rx.shouldHideNavigationBar().emit(to: me.rx.setTabBarHidden(animated: true)),
            ]
            let events: [Signal<RankStateObject.Event>] = [
                .just(.onTriggerReload),
                .never(),
                ]
            return Bindings(subscriptions: subscriptions, events: events)
        }
        
        let queryMedia: Feedback = react(query: { $0.hotMediaQuery }, effects: composeEffects(shouldQuery: { [weak self] in self?.shouldReactQuery ?? false  }) { query in
            ApolloClient.shared.rx.fetch(query: query, cachePolicy: .fetchIgnoringCacheData)
                .map { $0?.data?.hotMedia.fragments.cursorMediaFragment }.unwrap()
                .map(RankStateObject.Event.onGetData)
                .retryWhen { errors -> Observable<Int> in
                    errors.enumerated().flatMapLatest { Observable<Int>.timer(5 * RxTimeInterval($0.index + 1), scheduler: MainScheduler.instance) }
                }
                .asSignal(onErrorReturnJust: RankStateObject.Event.onGetError)
        })
        
        let states = store.states
        
        Signal.merge(
            vcFeedback(states),
            uiFeedback(states),
            queryMedia(states)
            )
            .debug("RankState.Event", trimOutput: true)
            .emit(onNext: store.on)
            .disposed(by: disposeBag)
        
        presenter.collectionView.rx.setDelegate(presenter).disposed(by: disposeBag)
    }
}

extension RankStateObject {
    
    var footerState: LoadFooterViewState {
        if isReloadHotMedia {
            return .empty
        }
        if !isReloadHotMedia && triggerHotMediaQuery {
            return .loading
        }
        if hotMediaError != nil {
            return .message("💁🏻‍♀️ 加载失败，请重试")
        }
        return .empty
    }
}
