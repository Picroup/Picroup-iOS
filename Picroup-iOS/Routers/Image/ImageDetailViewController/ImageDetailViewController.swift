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

private func mapMoreButtonTapToEvent(sender: UICollectionView) -> (ImageDetailStateObject) -> Signal<ImageDetailStateObject.Event> {
    return { state in
        
        guard state.session?.isLogin == true else { return .empty() }
        guard let cell = sender.cellForItem(at: IndexPath(item: 0, section: 0)) as? ImageDetailCell else { return .empty() }
        let isMyMedium = state.medium?.userId == state.session?.currentUser?._id
        let actions = isMyMedium ? ["删除"] : ["举报"]
        return DefaultWireframe.shared
            .promptFor(sender: cell.moreButton, cancelAction: "取消", actions: actions)
            .asSignalOnErrorRecoverEmpty()
            .flatMap { action in
                switch action {
                case "举报":     return .just(.onTriggerMediumFeedback)
                case "删除":     return comfirmDelete()
                default:        return .empty()
                }
        }
    }
}

private func comfirmDelete() -> Signal<ImageDetailStateObject.Event> {
    return DefaultWireframe.shared
        .promptFor(message: "确定要删除它吗？", preferredStyle: .alert, sender: nil, cancelAction: "取消", actions: ["删除"])
        .asSignalOnErrorRecoverEmpty()
        .flatMap { action in
            switch action {
            case "删除":     return .just(.onTriggerDeleteMedium)
            default:        return .empty()
            }
    }
}

fileprivate typealias Section = ImageDetailPresenter.Section
fileprivate typealias CellStyle = ImageDetailPresenter.CellStyle

class ImageDetailViewController: ShowNavigationBarViewController {
    
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
        
        let _events = PublishRelay<ImageDetailStateObject.Event>()
        let _moreButtonTap = PublishRelay<Void>()
        
        // I known this is ugly but it enabled the transition animations
        Observable.combineLatest(store.sections, store.states.asObservable()) { $1.isMediumDeleted ? [] : $0 }
            .bind(to: presenter.items(events: _events, moreButtonTap: _moreButtonTap))
            .disposed(by: disposeBag)
        
        let uiFeedback: Feedback = bind(self) { (me, state) in
            let presenter = me.presenter!

            let subscriptions = [
                state.map { $0.isMediumDeleted }.drive(onNext: { presenter.collectionView.backgroundView = $0 ? presenter.deleteAlertView : nil }),
                presenter.backgroundButton.rx.tap.subscribe(onNext: { _events.accept(.onTriggerPop) }),
                presenter.collectionView.rx.shouldHideNavigationBar().emit(to: me.rx.setNavigationBarHidden(animated: true)),
                ]
            let events: [Signal<ImageDetailStateObject.Event>] = [
                .just(.onTriggerReloadData),
                _events.asSignal(),
                _moreButtonTap.asSignal().withLatestFrom(state).flatMapLatest(mapMoreButtonTapToEvent(sender: presenter.collectionView)),
                state.flatMapLatest {
                    $0.shouldQueryMoreRecommendMedia
                        ? presenter.collectionView.rx.triggerGetMore
                        : .empty()
                    }.map { .onTriggerGetMoreData },
                me.presenter.collectionView.rx.modelSelected(ImageDetailPresenter.CellStyle.self).asSignal()
                    .flatMapLatest { cellStyle -> Signal<ImageDetailStateObject.Event> in
                    if case .recommendMedium(let medium) = cellStyle {
                        return .just(.onTriggerShowImage(medium._id))
                    }
                    return .empty()
                },
                presenter.deleteAlertView.rx.tapGesture().when(.recognized).asSignalOnErrorRecoverEmpty().map { _ in .onTriggerPop },
            ]
            return Bindings(subscriptions: subscriptions, events: events)
        }
        
        let queryMedium: Feedback = react(query: { $0.mediumQuery }, effects: composeEffects(shouldQuery: { [weak self] in self?.shouldReactQuery ?? false  }) { query in
            ApolloClient.shared.rx.fetch(query: query, cachePolicy: .fetchIgnoringCacheData)
                .map { $0?.data?.medium }
                .map(ImageDetailStateObject.Event.onGetData(isReload: query.cursor == nil))
                .asSignal(onErrorReturnJust: ImageDetailStateObject.Event.onGetError)
                .delay(0.4)
        })
        
        let starMedium: Feedback = react(query: { $0.starMediumQuery }, effects: composeEffects(shouldQuery: { [weak self] in self?.shouldReactQuery ?? false  }) { query in
            ApolloClient.shared.rx.perform(mutation: query)
                .map { $0?.data?.starMedium }.unwrap()
                .map(ImageDetailStateObject.Event.onStarMediumSuccess)
                .asSignal(onErrorReturnJust: ImageDetailStateObject.Event.onStarMediumError)
        })
        
        let deleteMedium: Feedback = react(query: { $0.deleteMediumQuery }, effects: composeEffects(shouldQuery: { [weak self] in self?.shouldReactQuery ?? false  }) { query in
            ApolloClient.shared.rx.perform(mutation: query)
                .map { $0?.data?.deleteMedium }.unwrap()
                .map(ImageDetailStateObject.Event.onDeleteMediumSuccess)
                .asSignal(onErrorReturnJust: ImageDetailStateObject.Event.onDeleteMediumError)
        })
        
        let states = store.states
        
        Signal.merge(
            uiFeedback(states),
            queryMedium(states),
            starMedium(states),
            deleteMedium(states)
            )
            .debug("ImageDetailState.Event", trimOutput: true)
            .emit(onNext: store.on)
            .disposed(by: disposeBag)
        
        presenter.collectionView.rx.setDelegate(presenter).disposed(by: disposeBag)
    }
}

extension ImageDetailStateStore {
    
    fileprivate var sections: Observable<[Section]> {
        return mediumWithRecommendMedia().map { data in
            let (medium, items) = data
            let imageDetailItems = [CellStyle.imageDetail(medium)]
            let recommendMediaItems = items.map(CellStyle.recommendMedium)
            let imageDetailSection = ImageDetailPresenter.Section(model: .imageDetail, items: imageDetailItems)
            let recommendMediaSection = ImageDetailPresenter.Section(model: .recommendMedia, items: recommendMediaItems)
            return [
                imageDetailSection,
                recommendMediaSection
            ]
        }
    }
}
