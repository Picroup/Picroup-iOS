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
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
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
        
        let uiFeedback: Feedback = bind(self) { (me, state)  in
            let subscriptions = [
                state.map { [Section(model: "", items: $0.items)] }.drive(me.presenter.items),
                state.map { $0.nextRankedMediaQuery.category }.map { $0?.name ?? "全部" }.drive(onNext: { titleLabel in { titleLabel.text = $0 }}(me.presenter.navigationItem.titleLabel)),
//                state.map { $0.hasMore }.drive(Binder(me.collectionView) { collectionView, hasMore in
//                    collectionView.contentInset.bottom = hasMore ? 64 : 2
//                })
            ]
            let events: [Signal<RankState.Event>] = [
                state.flatMapLatest {
                    $0.shouldQueryMore ? me.collectionView.rx.isNearBottom.asSignal() : .empty()
                    }.map { RankState.Event.onTriggerGetMore },
                state.flatMapLatest { state in
                    me.presenter.categoryButton.rx.tap.asSignal().flatMapLatest { _ in
                        let selected = PublishRelay<MediumCategory?>()
                        let vc = RouterService.Image.selectCategoryViewController(dependency: (state.nextRankedMediaQuery.category, selected.accept))
                        me.present(vc, animated: true)
                        return selected.asSignal().map { RankState.Event.onChangeCategory($0) }
                    }
                },
                
            ]
            return Bindings(subscriptions: subscriptions, events: events)
        }
        
        let queryMedia: Feedback = react(query: { $0.rankedMediaQuery }) { query in
            ApolloClient.shared.rx.fetch(query: query, cachePolicy: .fetchIgnoringCacheData).map { $0?.data?.rankedMedia }.unwrap()
                .map(RankState.Event.onGetSuccess)
                .asSignal(onErrorRecover: { error in .just(.onGetError(error) )})
        }
        
        let syncLocalStorage: Feedback = bind(LocalStorage.standard) { (localStorage, state) in
            let subscriptions = [
                state.map { $0.nextRankedMediaQuery.category }.drive(onNext: { localStorage.rankImageSelectedCategory = $0 })
            ]
            let events = [
                Signal<RankState.Event>.never()
            ]
            return Bindings(subscriptions: subscriptions, events: events)
        }
        
        Driver<Any>.system(
            initialState: RankState.empty(selectedCategory: LocalStorage.standard.rankImageSelectedCategory),
            reduce: logger(identifier: "RankState")(RankState.reduce),
            feedback: uiFeedback, queryMedia, syncLocalStorage
        )
        .drive()
        .disposed(by: disposeBag)
        
        collectionView.rx.modelSelected(RankedMediaQuery.Data.RankedMedium.Item.self)
            .subscribe(onNext: { [weak self] item in
                let vc = RouterService.Image.imageDetailViewController(dependency: item)
                self?.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)
    }
}

class RankMediumCell: RxCollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var starPlaceholderView: UIView!
}

extension RankedMediaQuery.Data.RankedMedium.Item: IdentifiableType, Equatable {
    
    public var identity: String {
        return id
    }
    
    public static func ==(lhs: RankedMediaQuery.Data.RankedMedium.Item, rhs: RankedMediaQuery.Data.RankedMedium.Item) -> Bool {
        return true
    }
}

extension RankedMediaQuery.Data.RankedMedium.Item {
    
    var remainTime: TimeInterval {
        return endedAt - Date().timeIntervalSince1970
    }
}
