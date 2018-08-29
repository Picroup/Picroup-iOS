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
import RealmSwift

final class RankViewController: BaseViewController {
    
    @IBOutlet var presenter: RankViewPresenter!
    
//    typealias Feedback = (Driver<RankStateObject>) -> Signal<RankStateObject.Event>
    typealias State = RankStateObject
    typealias Event = State.Event

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.setup(navigationItem: navigationItem)
        setupRxFeedback()
    }
    
    private func setupRxFeedback() {
        
        guard let realm = try? Realm(), let state = try? State.create()(realm) else { return }

//        guard let store = try? RankStateStore() else { return }
        
        state.system(
            uiFeedback: uiFeedback,
            shouldQuery: { [weak self] in self?.shouldReactQuery ?? false  },
            queryMedia: { query in
                return ApolloClient.shared.rx.fetch(query: query, cachePolicy: .fetchIgnoringCacheData)
                    .map { $0?.data?.hotMediaByTags.fragments.cursorMediaFragment }.forceUnwrap()
                    .retryWhen { errors -> Observable<Int> in
                        errors.enumerated().flatMapLatest { Observable<Int>.timer(5 * RxTimeInterval($0.index + 1), scheduler: MainScheduler.instance) }
                    }
                    .delay(0.3, scheduler: MainScheduler.instance)
        }
        )
        .drive()
        .disposed(by: disposeBag)
        
        
    }
    
    var uiFeedback: State.DriverFeedback {
        typealias Section = MediaPreserter.Section
        let footerState = BehaviorRelay<LoadFooterViewState>(value: .empty)
        return bind(self) { (me, state)  in
            let presenter = me.presenter!
            let view = me.view!
            let subscriptions = [
                state.map { $0.tagStates() }.drive(presenter.tagsCollectionView.rx.items(cellIdentifier: "TagCollectionViewCell", cellType: TagCollectionViewCell.self)) { index, tagState, cell in
                    cell.tagLabel.text = tagState.tag
                    cell.setSelected(tagState.isSelected)
                },
                state.map { [Section(model: "", items: $0.hotMediaItems())] }.drive(presenter.mediaPresenter.items(footerState: footerState.asDriver())),
                state.map { $0.hotMediaQueryState?.isReload ?? false }.drive(presenter.refreshControl.rx.refreshing),
                state.map { $0.hotMediaQueryState?.footerState ?? .empty }.drive(footerState),
                state.map { $0.sessionState?.isLogin ?? false }.drive(presenter.userButton.rx.isHidden),
                presenter.collectionView.rx.shouldHideNavigationBar().emit(to: me.rx.setNavigationBarHidden(animated: true)),
                presenter.collectionView.rx.shouldHideNavigationBar().emit(to: me.rx.setTabBarHidden(animated: true)),
                presenter.collectionView.rx.shouldHideNavigationBar().emit(onNext: {
                    presenter.hideTagsLayoutConstraint.isActive = $0
                    UIView.animate(withDuration: 0.3) { view.layoutIfNeeded() }
                }),
                presenter.collectionView.rx.setDelegate(presenter.mediaPresenter),
                ]
            let events: [Signal<Event>] = [
                .just(.onTriggerReloadHotMedia),
                presenter.tagsCollectionView.rx.modelSelected(TagStateObject.self).asSignal().map { .onToggleTag($0.tag) },
                state.flatMapLatest {
                    ($0.hotMediaQueryState?.shouldQueryMore ?? false)
                        ? presenter.collectionView.rx.triggerGetMore
                        : .empty()
                    }.map { .onTriggerGetMoreHotMedia },
                presenter.refreshControl.rx.controlEvent(.valueChanged).asSignal().map { .onTriggerReloadHotMedia },
                presenter.collectionView.rx.modelSelected(MediumObject.self).asSignal().map { .onTriggerShowImage($0._id) },
                presenter.userButton.rx.tap.asSignal().map { .onTriggerLogin },
                ]
            return Bindings(subscriptions: subscriptions, events: events)
        }
    }
}

extension RankStateObject {
    
    func hotMediaItems() -> [MediumObject] {
        return hotMediaQueryState?.cursorMedia?.items.toArray() ?? []
    }
    
    func tagStates() -> [TagStateObject] {
        return hotMediaTagsState?.tagStates.toArray() ?? []
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
