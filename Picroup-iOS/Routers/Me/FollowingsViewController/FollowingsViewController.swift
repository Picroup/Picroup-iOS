//
//  FollowingsViewController.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/21.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import Apollo
import RxSwift
import RxCocoa
import RxDataSources
import RxFeedback


class FollowingsViewController: HideNavigationBarViewController {
    
    typealias Dependency = String
    var dependency: Dependency!
    
    @IBOutlet var presenter: FollowingsPresenter!
    fileprivate typealias Feedback = (Driver<UserFollowingsStateObject>) -> Signal<UserFollowingsStateObject.Event>

    override func viewDidLoad() {
        super.viewDidLoad()
        setupRxFeedback()
    }
    
    private func setupRxFeedback() {
        
        guard
            let userId = dependency,
            let store = try? UserFollowingsStateStore(userId: userId) else {
                return
        }
        
        typealias Section = FollowingsPresenter.Section
        
        let view = self.view!
        
        let uiFeedback: Feedback = bind(presenter) { (presenter, state)  in
            let subscriptions = [
                state.map { $0.user?.followingsCount.value?.description ?? "0" }.drive(presenter.followingsCountLabel.rx.text),
                store.userFollowingsItems().map { [Section(model: "", items: $0)] }.drive(presenter.items),
                ]
            let events: [Signal<UserFollowingsStateObject.Event>] = [
                state.flatMapLatest {
                    $0.shouldQueryMoreUserFollowings
                        ? presenter.tableView.rx.triggerGetMore
                        : .empty()
                    }.map { .onTriggerGetMoreUserFollowings },
                .just(.onTriggerReloadUserFollowings),
                view.rx.tapGesture().when(.recognized).asSignalOnErrorRecoverEmpty().map { _ in .onTriggerPop },
                ]
            return Bindings(subscriptions: subscriptions, events: events)
        }
        
        let queryUserFollowings: Feedback = react(query: { $0.userFollowingsQuery }) { query in
            ApolloClient.shared.rx.fetch(query: query, cachePolicy: .fetchIgnoringCacheData).map { $0?.data?.user?.followings }.unwrap()
                .map(UserFollowingsStateObject.Event.onGetUserFollowings(isReload: query.cursor == nil))
                .asSignal(onErrorReturnJust: UserFollowingsStateObject.Event.onGetUserFollowingsError)
        }
        
        let states = store.states
        
        Signal.merge(
            uiFeedback(states),
            queryUserFollowings(states)
            )
            .debug("UserFollowingsStateObject.Event", trimOutput: true)
            .emit(onNext: store.on)
            .disposed(by: disposeBag)
        
    }
}

final class FollowingsPresenter: NSObject {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var followingsCountLabel: UILabel!

    typealias Section = AnimatableSectionModel<String, UserObject>
    typealias DataSource = RxTableViewSectionedAnimatedDataSource<Section>
    
    var items: (Observable<[Section]>) -> Disposable {
        let dataSource = DataSource(
            configureCell: { dataSource, tableView, indexPath, item in
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
//                cell.configure(with: item)
                return cell
        })
        return tableView.rx.items(dataSource: dataSource)
    }
}


