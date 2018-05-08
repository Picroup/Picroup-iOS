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
    typealias Feedback = (Driver<RankState>) -> Signal<RankState.Event>
    
    override func didMove(toParentViewController parent: UIViewController?) {
        super.didMove(toParentViewController: parent)
        presenter = RankViewPresenter(collectionView: collectionView, navigationItem: navigationItem)
        setupRxFeedback()
    }
    
    private func setupRxFeedback() {
        
        typealias Section = RankViewPresenter.Section
        
        let uiFeedback: Feedback = bind(presenter) { (presenter, state)  in
            let subscriptions = [
                state.map { [Section(model: "", items: $0.items)] }.drive(presenter.items),
                presenter.categoryButton.rx.tap.asSignal().emit(onNext: store.onLogout)
            ]
            let events: [Signal<RankState.Event>] = [
                state.flatMapLatest {
                    $0.shouldQueryMore ? presenter.collectionView.rx.isNearBottom.asSignal() : .empty()
                    }.map { .onTriggerGetMore },
            ]
            return Bindings(subscriptions: subscriptions, events: events)
        }
        
        let vcFeedback: Feedback = bind(self) { (me, state)  in
            let subscriptions = [
                me.collectionView.rx.modelSelected(RankedMediaQuery.Data.RankedMedium.Item.self).asSignal().emit(to:
                    Binder(me) { me, item in
                        let vc = RouterService.Image.imageDetailViewController(dependency: item)
                        me.navigationController?.pushViewController(vc, animated: true)
                }),
                me.collectionView.rx.shouldHideNavigationBar()
                    .emit(to: me.rx.setNavigationBarHidden(animated: true))
            ]
            let events: [Signal<RankState.Event>] = [
                .never(),
                ]
            return Bindings(subscriptions: subscriptions, events: events)
        }
        
        let queryMedia: Feedback = react(query: { $0.rankedMediaQuery }) { query in
            ApolloClient.shared.rx.fetch(query: query, cachePolicy: .fetchIgnoringCacheData).map { $0?.data?.rankedMedia }.unwrap()
                .map(RankState.Event.onGetSuccess)
                .asSignal(onErrorRecover: { error in .just(.onGetError(error) )})
        }
        
        Driver<Any>.system(
            initialState: RankState.empty(),
            reduce: logger(identifier: "RankState")(RankState.reduce),
            feedback: uiFeedback, vcFeedback, queryMedia
        )
        .drive()
        .disposed(by: disposeBag)
    }

}

class RankMediumCell: RxCollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var starPlaceholderView: UIView!
}

