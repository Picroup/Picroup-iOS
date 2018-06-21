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

final class UpdateUserViewController: HideNavigationBarViewController {
    
    @IBOutlet fileprivate weak var presenter: UpdateUserPresenter!
    fileprivate typealias Feedback = (Driver<UpdateUserStateObject>) -> Signal<UpdateUserStateObject.Event>

    override func viewDidLoad() {
        super.viewDidLoad()
        setupRxFeedback()
    }
    
    private func setupRxFeedback() {
        
        guard let store = try? UpdateUserStateStore()  else { return }
        
        weak var weakSelf = self
        let uiFeedback: Feedback = bind(self) { (me, state) in
            let presenter = me.presenter!
            let subscriptions = [
                state.map { $0.session?.currentUser }.drive(presenter.userAvatarImageView.rx.userAvatar),
                state.map { $0.triggerSetAvatarIdQuery }.drive(presenter.userAvatarSpinner.rx.isAnimating),
                state.map { $0.displayName }.asObservable().take(1).bind(to: presenter.displaynameField.rx.text),
                state.map { $0.session?.currentUser?.username.map { "@\($0)" } ?? " " }.drive(presenter.usernameLabel.rx.text),
                ]
            let events: [Signal<UpdateUserStateObject.Event>] = [
                presenter.displaynameField.rx.text.orEmpty.asSignalOnErrorRecoverEmpty().debounce(0.5).skip(2)
                    .map(UpdateUserStateObject.Event.onTriggerSetDisplayName),
                presenter.headerView.rx.tapGesture().when(.recognized).asSignalOnErrorRecoverEmpty().map { _ in .onTriggerPop },
                presenter.userAvatarImageView.rx.tapGesture().when(.recognized).asSignalOnErrorRecoverEmpty().flatMapLatest { _ in
                    PhotoPickerProvider.pickImages(from: weakSelf, imageLimit: 1).map { $0.first }.unwrap()
                    }.map(UpdateUserStateObject.Event.onChangeImageKey)
                ]
            return Bindings(subscriptions: subscriptions, events: events)
        }
        
        let querySetImageKey: Feedback = react(query: { $0.setImageKeyQuery }, effects: composeEffects(shouldQuery: { [weak self] in self?.shouldReactQuery ?? false  }) { query in
            let image = ImageCache.default.retrieveImageInMemoryCache(forKey: query.imageKey)!
            let (progress, filename) = ImageUpoader.uploadImage(image)
            let next = UserSetAvatarIdQuery(userId: query.userId, avatarId: filename)
            return Observable.concat([
                progress.flatMap { _ in Observable<UpdateUserStateObject.Event>.empty() },
                ApolloClient.shared.rx.fetch(query: next, cachePolicy: .fetchIgnoringCacheData).asObservable()
                    .map { $0?.data?.user?.setAvatarId.fragments.userFragment }.unwrap()
                    .map(UpdateUserStateObject.Event.onSetAvatarIdSuccess)
                ])
                .asSignal(onErrorReturnJust: UpdateUserStateObject.Event.onSetAvatarIdError)
        })
        
        let querySetDisplayName: Feedback = react(query: { $0.setDisplayNameQuery }, effects: composeEffects(shouldQuery: { [weak self] in self?.shouldReactQuery ?? false  }) { query in
            ApolloClient.shared.rx.fetch(query: query, cachePolicy: .fetchIgnoringCacheData)
                .map { $0?.data?.user?.setDisplayName.fragments.userFragment }.unwrap()
                .map(UpdateUserStateObject.Event.onSetDisplayNameSuccess)
                .asSignal(onErrorReturnJust: UpdateUserStateObject.Event.onSetDisplayNameError)
        })
        
        let states = store.states
            .debug("UpdateUserState", trimOutput: false)

        Signal.merge(
            uiFeedback(states),
            querySetImageKey(states),
            querySetDisplayName(states)
            )
            .debug("UpdateUserState.Event", trimOutput: true)
            .emit(onNext: store.on)
            .disposed(by: disposeBag)

    }
}
