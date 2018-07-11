//
//  TagMediaViewController.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/7/11.
//  Copyright © 2018年 luojie. All rights reserved.
//


import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import RxFeedback
import Material
import Apollo

final class TagMediaViewController: ShowNavigationBarViewController {
    
    typealias Dependency = String
    var dependency: Dependency!
    
    @IBOutlet var presenter: TagMediaViewPresenter!
    
    typealias Feedback = (Driver<TagMediaStateObject>) -> Signal<TagMediaStateObject.Event>
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.setup(navigationItem: navigationItem)
        setupRxFeedback()
    }
    
    private func setupRxFeedback() {
        
        guard let tag = dependency,
            let store = try? TagMediaStateObjectStore(tag: tag) else { return }
        
        typealias Section = TagMediaViewPresenter.Section
        
        let uiFeedback: Feedback = bind(presenter) { (presenter, state)  in
            let footerState = BehaviorRelay<LoadFooterViewState>(value: .empty)
            let subscriptions = [
                state.map { "# \($0.tag)" }.drive(presenter.navigationItem.titleLabel.rx.text),
                store.hotMediaItems().map { [Section(model: "", items: $0)] }.drive(presenter.items(footerState.asDriver())),
                state.map { $0.isReloadHotMedia }.drive(presenter.refreshControl.rx.refreshing),
                state.map { $0.footerState }.drive(footerState),
                ]
            let events: [Signal<TagMediaStateObject.Event>] = [
                state.flatMapLatest {
                    $0.shouldQueryMoreHotMedia
                        ? presenter.collectionView.rx.triggerGetMore
                        : .empty()
                    }.map { .onTriggerGetMore },
                presenter.refreshControl.rx.controlEvent(.valueChanged).asSignal().map { .onTriggerReload },
                presenter.collectionView.rx.modelSelected(MediumObject.self).asSignal().map { .onTriggerShowImage($0._id) },
                ]
            return Bindings(subscriptions: subscriptions, events: events)
        }
        
        let vcFeedback: Feedback = bind(self) { (me, state)  in
            let presenter = me.presenter!
            let subscriptions = [
                presenter.collectionView.rx.shouldHideNavigationBar().emit(to: me.rx.setNavigationBarHidden(animated: true)),
                presenter.collectionView.rx.shouldHideNavigationBar().emit(to: me.rx.setTabBarHidden(animated: true)),
                ]
            let events: [Signal<TagMediaStateObject.Event>] = [
                .just(.onTriggerReload),
                .never(),
                ]
            return Bindings(subscriptions: subscriptions, events: events)
        }
        
        let queryMedia: Feedback = react(query: { $0.hotMediaQuery }, effects: composeEffects(shouldQuery: { [weak self] in self?.shouldReactQuery ?? false  }) { query in
            ApolloClient.shared.rx.fetch(query: query, cachePolicy: .fetchIgnoringCacheData)
                .map { $0?.data?.hotMediaByTags.fragments.cursorMediaFragment }.unwrap()
                .map(TagMediaStateObject.Event.onGetData)
                .retryWhen { errors -> Observable<Int> in
                    errors.enumerated().flatMapLatest { Observable<Int>.timer(5 * RxTimeInterval($0.index + 1), scheduler: MainScheduler.instance) }
                }
                .asSignal(onErrorReturnJust: TagMediaStateObject.Event.onGetError)
                .delay(0.3)
        })
        
        let states = store.states
        
        Signal.merge(
            vcFeedback(states),
            uiFeedback(states),
            queryMedia(states)
            )
            .debug("TagMediaState.Event", trimOutput: true)
            .emit(onNext: store.on)
            .disposed(by: disposeBag)
        
        presenter.collectionView.rx.setDelegate(presenter).disposed(by: disposeBag)
    }
}

extension TagMediaStateObject {
    
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
