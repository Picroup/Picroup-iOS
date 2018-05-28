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

class RankViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    private var presenter: RankViewPresenter!
    
    private let disposeBag = DisposeBag()
    typealias Feedback = (Driver<RankStateObject>) -> Signal<RankStateObject.Event>
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = RankViewPresenter(collectionView: collectionView, navigationItem: navigationItem)
        setupRxFeedback()
    }
    
    private func setupRxFeedback() {
        
        guard let store = try? RankStateStore() else { return }
        
        typealias Section = RankViewPresenter.Section
        
        let uiFeedback: Feedback = bind(presenter) { (presenter, state)  in
            let footerState = PublishRelay<LoadFooterViewState>()
            let subscriptions = [
                store.rankMediaItems().map { [Section(model: "", items: $0)] }.drive(presenter.items(footerState.asSignal())),
                state.map { $0.isReloading }.drive(presenter.refreshControl.rx.isRefreshing),
                state.map { $0.footerState }.asSignalOnErrorRecoverEmpty().emit(to: footerState),
            ]
            let events: [Signal<RankStateObject.Event>] = [
                state.flatMapLatest {
                    $0.shouldQueryMoreRankedMedia
                        ? presenter.collectionView.rx.triggerGetMore
                        : .empty()
                }.map { .onTriggerGetMore },
                presenter.refreshControl.rx.controlEvent(.valueChanged).asSignal().map { .onTriggerReload },
                presenter.collectionView.rx.modelSelected(MediumObject.self).asSignal().map { .onTriggerShowImage($0._id) },
                presenter.categoryButton.rx.tap.asSignal().withLatestFrom(state)
                    .map { $0.session?.isLogin ?? false }
                    .map { isLogin in isLogin ? .onLogout : .onTriggerLogin },
            ]
            return Bindings(subscriptions: subscriptions, events: events)
        }
        
        let vcFeedback: Feedback = bind(self) { (me, state)  in
            let subscriptions = [
                me.collectionView.rx.shouldHideNavigationBar().emit(to: me.rx.setNavigationBarHidden(animated: true))
            ]
            let events: [Signal<RankStateObject.Event>] = [
                .just(.onTriggerReload),
                .never()
                ]
            return Bindings(subscriptions: subscriptions, events: events)
        }
        
        let queryMedia: Feedback = react(query: { $0.rankedMediaQuery }) { query in
            ApolloClient.shared.rx.fetch(query: query, cachePolicy: .fetchIgnoringCacheData)
                .map { $0?.data?.rankedMedia.fragments.cursorMediaFragment }.unwrap()
                .map(RankStateObject.Event.onGetData(isReload: query.cursor == nil))
                .asSignal(onErrorReturnJust: RankStateObject.Event.onGetError)
        }
        
        let states = store.states
        
        Signal.merge(
            vcFeedback(states),
            uiFeedback(states),
            queryMedia(states)
            )
            .debug("RankState.Event", trimOutput: true)
            .emit(onNext: store.on)
            .disposed(by: disposeBag)
    }
}

extension RankStateObject {
    
    var footerState: LoadFooterViewState {
        let (cursor, trigger, error) = (rankMedia?.cursor.value, triggerRankedMediaQuery, rankedMediaError)
        return LoadFooterViewState.create(cursor: cursor, trigger: trigger, error: error)
    }
}
