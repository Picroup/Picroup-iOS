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
        
        guard let stateStore = try? RankStateStore() else { return }
        
        typealias Section = RankViewPresenter.Section
        
        let uiFeedback: Feedback = bind(presenter) { (presenter, state)  in
            let subscriptions = [
                stateStore.rankMediaItems().map { [Section(model: "", items: $0.toArray())] }.drive(presenter.items),
                presenter.categoryButton.rx.tap.asSignal().emit(onNext: store.onLogout)
            ]
            let events: [Signal<RankStateObject.Event>] = [
                state.flatMapLatest {
                    $0.shouldQueryMoreRankedMedia
                        ? presenter.collectionView.rx.triggerGetMore.map { .onTriggerGetMore }
                        : .empty()
                },
            ]
            return Bindings(subscriptions: subscriptions, events: events)
        }
        
        let vcFeedback: Feedback = bind(self) { (me, state)  in
            let subscriptions = [
                me.collectionView.rx.modelSelected(MediumObject.self).asSignal().emit(to:
                    Binder(me) { me, item in
//                        let vc = RouterService.Image.imageDetailViewController(dependency: item)
//                        me.navigationController?.pushViewController(vc, animated: true)
                }),
                me.collectionView.rx.shouldHideNavigationBar()
                    .emit(to: me.rx.setNavigationBarHidden(animated: true))
            ]
            let events: [Signal<RankStateObject.Event>] = [
                Signal.just(RankStateObject.Event.onTriggerReload),
                .never()
                ]
            return Bindings(subscriptions: subscriptions, events: events)
        }
        
        let queryMedia: Feedback = react(query: { $0.rankedMediaQuery }) { query in
            ApolloClient.shared.rx.fetch(query: query, cachePolicy: .fetchIgnoringCacheData).map { $0?.data?.rankedMedia.fragments.cursorMediaFragment }.unwrap()
                .map(RankStateObject.Event.onGetData(isReload: query.cursor == nil))
                .asSignal(onErrorReturnJust: RankStateObject.Event.onGetError)
        }
        
        let states = stateStore.states
        
        Signal.merge(
            vcFeedback(states),
            uiFeedback(states),
            queryMedia(states)
            )
            .debug("RankStateObject.Event")
            .emit(onNext: stateStore.on)
            .disposed(by: disposeBag)
    }

}
