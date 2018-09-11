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
import RealmSwift

final class TagMediaViewController: ShowNavigationBarViewController, IsStateViewController {
    
    typealias State = TagMediaStateObject
    typealias Event = State.Event
    
    typealias Dependency = String
    var dependency: Dependency!
    
    @IBOutlet var presenter: TagMediaViewPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.setup(navigationItem: navigationItem)
        setupRxFeedback()
    }
    
    private func setupRxFeedback() {
        
        guard let tag = dependency,
            let realm = try? Realm(),
            let state = try? State.create(tag: tag)(realm) else { return }
        
        state.system(
            uiFeedback: uiFeedback,
            shouldQuery: { [weak self] in self?.shouldReactQuery ?? false  },
            queryMedia: { query in
                return ApolloClient.shared.rx.fetch(query: query, cachePolicy: .fetchIgnoringCacheData)
                    .map { ($0?.data?.hotMediaByTags.snapshot).map(CursorMediaFragment.init(snapshot: )) }.forceUnwrap()
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
            let subscriptions = [
                state.map { "# \($0.tag)" }.drive(presenter.navigationItem.titleLabel.rx.text),
                state.map { [Section(model: "", items: $0.hotMediaItems())] }.drive(presenter.mediaPresenter.items(footerState: footerState.asDriver())),
                state.map { $0.hotMediaQueryState?.isReload ?? false }.drive(presenter.refreshControl.rx.refreshing),
                state.map { $0.hotMediaQueryState?.footerState ?? .empty }.drive(footerState),
                presenter.collectionView.rx.shouldHideNavigationBar().emit(to: me.rx.setNavigationBarHidden(animated: true)),
                presenter.collectionView.rx.shouldHideNavigationBar().emit(to: me.rx.setTabBarHidden(animated: true)),
                presenter.collectionView.rx.setDelegate(presenter.mediaPresenter),
                ]
            let events: [Signal<TagMediaStateObject.Event>] = [
                .just(.onTriggerReloadHotMedia),
                state.flatMapLatest {
                    ($0.hotMediaQueryState?.shouldQueryMore ?? false)
                        ? presenter.collectionView.rx.triggerGetMore
                        : .empty()
                    }.map { .onTriggerGetMoreHotMedia },
                presenter.refreshControl.rx.controlEvent(.valueChanged).asSignal().map { .onTriggerReloadHotMedia },
                presenter.collectionView.rx.modelSelected(MediumObject.self).asSignal().map { .onTriggerShowImage($0._id) },
                ]
            return Bindings(subscriptions: subscriptions, events: events)
        }
    }
}

extension TagMediaStateObject {
    
    func hotMediaItems() -> [MediumObject] {
        return hotMediaQueryState?.cursorMedia?.items.toArray() ?? []
    }
}
