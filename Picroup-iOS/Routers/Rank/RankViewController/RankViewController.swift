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

final class RankViewController: BaseViewController {
    
    @IBOutlet var presenter: RankViewPresenter!
    
    typealias Feedback = (Driver<RankStateObject>) -> Signal<RankStateObject.Event>
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.setup(navigationItem: navigationItem)
        setupRxFeedback()
    }
    
    private func setupRxFeedback() {
        
        guard let store = try? RankStateStore() else { return }
        
        typealias Section = MediaPreserter.Section
                
        let uiFeedback: Feedback = bind(presenter) { (presenter, state)  in
            let footerState = BehaviorRelay<LoadFooterViewState>(value: .empty)
            let subscriptions = [
                store.tagStates().drive(presenter.tagsCollectionView.rx.items(cellIdentifier: "TagCollectionViewCell", cellType: TagCollectionViewCell.self)) { index, tagState, cell in
                    cell.tagLabel.text = tagState.tag
                    cell.setSelected(tagState.isSelected)
                },
                store.hotMediaItems().map { [Section(model: "", items: $0)] }.drive(presenter.mediaPresenter.items(footerState: footerState.asDriver())),
                state.map { $0.hotMediaState?.isReload ?? false }.drive(presenter.refreshControl.rx.refreshing),
                state.map { $0.hotMediaState?.footerState ?? .empty }.drive(footerState),
                state.map { $0.sessionState?.isLogin ?? false }.drive(presenter.userButton.rx.isHidden),
            ]
            let events: [Signal<RankStateObject.Event>] = [
                presenter.tagsCollectionView.rx.modelSelected(TagStateObject.self).asSignal().map { .onToggleTag($0.tag) },
                state.flatMapLatest {
                    ($0.hotMediaState?.shouldQueryMore ?? false)
                        ? presenter.collectionView.rx.triggerGetMore
                        : .empty()
                }.map { .hotMediaState(.onTriggerGetMore) },
                presenter.refreshControl.rx.controlEvent(.valueChanged).asSignal().map { .hotMediaState(.onTriggerReload) },
                presenter.collectionView.rx.modelSelected(MediumObject.self).asSignal().map { .onTriggerShowImage($0._id) },
                presenter.userButton.rx.tap.asSignal().map { .onTriggerLogin },
            ]
            return Bindings(subscriptions: subscriptions, events: events)
        }
        
        let vcFeedback: Feedback = bind(self) { (me, state)  in
            let presenter = me.presenter!
            let view = me.view!
            let subscriptions = [
                presenter.collectionView.rx.shouldHideNavigationBar().emit(to: me.rx.setNavigationBarHidden(animated: true)),
                presenter.collectionView.rx.shouldHideNavigationBar().emit(to: me.rx.setTabBarHidden(animated: true)),
                presenter.collectionView.rx.shouldHideNavigationBar().emit(onNext: {
                    presenter.hideTagsLayoutConstraint.isActive = $0
                    UIView.animate(withDuration: 0.3) { view.layoutIfNeeded() }
                    }),
            ]
            let events: [Signal<RankStateObject.Event>] = [
                .just(.hotMediaState(.onTriggerReload)),
                .never(),
                ]
            return Bindings(subscriptions: subscriptions, events: events)
        }
        
        let queryMedia: Feedback = react(query: { $0.hotMediaQuery }, effects: composeEffects(shouldQuery: { [weak self] in self?.shouldReactQuery ?? false  }) { query in
            ApolloClient.shared.rx.fetch(query: query, cachePolicy: .fetchIgnoringCacheData)
                .map { $0?.data?.hotMediaByTags.fragments.cursorMediaFragment }.unwrap()
                .map { .hotMediaState(.onGetSampleData($0)) }
                .retryWhen { errors -> Observable<Int> in
                    errors.enumerated().flatMapLatest { Observable<Int>.timer(5 * RxTimeInterval($0.index + 1), scheduler: MainScheduler.instance) }
                }
                .asSignal(onErrorReturnJust: { .hotMediaState(.onGetError($0)) })
                .delay(0.3)
        })
        
        let states = store.states
//            .debug("RankState")
        
        Signal.merge(
            vcFeedback(states),
            uiFeedback(states),
            queryMedia(states)
            )
            .debug("RankState.Event", trimOutput: true)
            .emit(onNext: store.on)
            .disposed(by: disposeBag)
        
        presenter.collectionView.rx.setDelegate(presenter.mediaPresenter).disposed(by: disposeBag)
    }
}

extension CursorMediaStateObject {
    
    var footerState: LoadFooterViewState {
        if isReload == true {
            return .empty
        }
        if isReload == false && trigger == true {
            return .loading
        }
        if error != nil {
            return .message("💁🏻‍♀️ 加载失败，请重试")
        }
        return .empty
    }
}
