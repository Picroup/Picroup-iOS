//
//  ImageDetailViewController.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/16.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import Material
import RxSwift
import RxCocoa
import RxFeedback
import Apollo

fileprivate typealias Section = ImageDetailPresenter.Section
fileprivate typealias CellStyle = ImageDetailPresenter.CellStyle

class ImageDetailViewController: HideNavigationBarViewController {
    
    typealias Dependency = String
    var dependency: Dependency!
    
    fileprivate typealias Feedback = (Driver<ImageDetailStateObject>) -> Signal<ImageDetailStateObject.Event>
    @IBOutlet var presenter: ImageDetailPresenter!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupRxFeedback()
    }
    
    private func setupRxFeedback() {
        
        guard
            let mediumId = dependency,
            let store = try? ImageDetailStateStore(mediumId: mediumId)
            else {
                return
        }
        
        appStateService?.events.accept(.onViewMedium(mediumId))

        let uiFeedback: Feedback = bind(self) { (me, state) in
            let presenter = me.presenter!
            
            let _events = PublishRelay<ImageDetailStateObject.Event>()
            
            let subscriptions = [
                store.sections.drive(me.presenter.items(
                    onStarButtonTap: { _events.accept(.onTriggerStarMedium) },
                    onCommentsTap: { _events.accept(.onTriggerShowComments) },
                    onImageViewTap: { _events.accept(.onTriggerPop) } ,
                    onUserTap: { _events.accept(.onTriggerShowUser) })),
                presenter.backgroundButton.rx.tap.subscribe(onNext: { _events.accept(.onTriggerPop) }),
                ]
            let events: [Signal<ImageDetailStateObject.Event>] = [
                state.flatMapLatest {
                    $0.shouldQueryMoreRecommendMedia
                        ? presenter.collectionView.rx.triggerGetMore
                        : .empty()
                    }.map { .onTriggerGetMoreData },
                .just(.onTriggerReloadData),
                _events.asSignal(),
                me.presenter.collectionView.rx.modelSelected(ImageDetailPresenter.CellStyle.self).asSignal()
                    .flatMapLatest { cellStyle -> Signal<ImageDetailStateObject.Event> in
                    if case .recommendMedium(let medium) = cellStyle {
                        return .just(.onTriggerShowImage(medium._id))
                    }
                    return .empty()
                }
            ]
            return Bindings(subscriptions: subscriptions, events: events)
        }
        
        let queryMedium: Feedback = react(query: { $0.mediumQuery }) { query in
            ApolloClient.shared.rx.fetch(query: query, cachePolicy: .fetchIgnoringCacheData)
                .map { $0?.data?.medium }.unwrap()
                .map(ImageDetailStateObject.Event.onGetData(isReload: query.cursor == nil))
                .asSignal(onErrorReturnJust: ImageDetailStateObject.Event.onGetError)
                .delay(1)
        }
        
        let starMedium: Feedback = react(query: { $0.starMediumQuery }) { query in
            ApolloClient.shared.rx.perform(mutation: query).asObservable()
                .map { $0?.data?.starMedium }.unwrap()
                .map(ImageDetailStateObject.Event.onStarMediumSuccess)
                .asSignal(onErrorReturnJust: ImageDetailStateObject.Event.onStarMediumError)
        }
        
        let states = store.states
        
        Signal.merge(
            uiFeedback(states),
            queryMedium(states),
            starMedium(states)
            )
            .debug("ImageDetailStateObject.Event", trimOutput: true)
            .emit(onNext: store.on)
            .disposed(by: disposeBag)
        
        presenter.collectionView.rx.setDelegate(presenter).disposed(by: disposeBag)
    }
}

extension ImageDetailStateStore {
    
    fileprivate var sections: Driver<[Section]> {
        return mediumWithRecommendMedia().map { data in
            let (medium, items) = data
            let imageDetailItems = [CellStyle.imageDetail(medium)]
            let recommendMediaItems = items.map(CellStyle.recommendMedium)
            let imageDetailSection = ImageDetailPresenter.Section(model: "imageDetail", items: imageDetailItems)
            let recommendMediaSection = ImageDetailPresenter.Section(model: "recommendMedia", items: recommendMediaItems)
            return [
                imageDetailSection,
                recommendMediaSection
            ]
        }
    }
}
