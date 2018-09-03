//
//  UpdateUserViewController.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/6/3.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import Material
import RxSwift
import RxCocoa
import RxFeedback
import Apollo
import Kingfisher
import RealmSwift

final class UpdateUserViewController: ShowNavigationBarViewController, IsStateViewController {
    
    typealias State = UpdateUserStateObject
    typealias Event = State.Event
    
    @IBOutlet fileprivate weak var presenter: UpdateUserPresenter!

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.setup(navigationItem: navigationItem)
        setupRxFeedback()
    }
    
    private func setupRxFeedback() {
        
        guard let realm = try? Realm(), let state = try? State.create()(realm) else { return }
        
        state.system(
            uiFeedback: uiFeedback,
            shouldQuery: { [weak self] in self?.shouldReactQuery ?? false  },
            querySetAvatar: { query in
                guard let pickedImage = ImageCache.default.retrieveImage(forKey: query.imageKey) else {
                    return Single.error(CacheError.imageNotCached)
                }
                let (progress, filename) = UpoaderService.uploadImage(pickedImage)
                let next = UserSetAvatarIdQuery(userId: query.userId, avatarId: filename)
                return Observable.concat([
                    progress.flatMap { _ in Observable<UserFragment>.empty() },
                    ApolloClient.shared.rx.fetch(query: next, cachePolicy: .fetchIgnoringCacheData)
                        .map { $0?.data?.user?.setAvatarId.fragments.userFragment }.forceUnwrap().asObservable()
                    ])
                    .asSingle()
        },
            querySetDisplayName: { query in
                return ApolloClient.shared.rx.fetch(query: query, cachePolicy: .fetchIgnoringCacheData)
                    .map { $0?.data?.user?.setDisplayName.fragments.userFragment }.forceUnwrap()
        })
            .drive()
            .disposed(by: disposeBag)

    }
    
    var uiFeedback: State.DriverFeedback {
        weak var weakSelf = self
        return bind(self) { (me, state) in
            let presenter = me.presenter!
            let subscriptions = [
                state.map { $0.sessionState?.currentUser }.drive(presenter.userAvatarImageView.rx.userAvatar),
                state.map { $0.setAvatarQueryState?.trigger ?? false }.drive(presenter.userAvatarSpinner.rx.isAnimating),
                state.map { $0.sessionState?.currentUser?.displayName }.asObservable().take(1).bind(to: presenter.displaynameField.rx.text),
                state.map { $0.sessionState?.currentUser?.username.map { "@\($0)" } ?? " " }.drive(presenter.usernameLabel.rx.text),
                ]
            let events: [Signal<UpdateUserStateObject.Event>] = [
                presenter.displaynameField.rx.text.orEmpty.asSignalOnErrorRecoverEmpty().debounce(0.5).skip(2).distinctUntilChanged()
                    .map(UpdateUserStateObject.Event.onTriggerSetDisplayName),
                //                presenter.headerView.rx.tapGesture().when(.recognized).asSignalOnErrorRecoverEmpty().map { _ in .onTriggerPop },
                presenter.userAvatarImageView.rx.tapGesture().when(.recognized).asSignalOnErrorRecoverEmpty().flatMapLatest { _ in
                    PhotoPickerProvider.pickImage(from: weakSelf)
                    }.map(UpdateUserStateObject.Event.onChangeImageKey)
            ]
            return Bindings(subscriptions: subscriptions, events: events)
        }
    }
}
