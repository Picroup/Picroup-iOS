//
//  HomeViewController.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/9.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import Material
import RxSwift
import RxCocoa
import RxFeedback
import Apollo

class HomeMenuViewController: FABMenuController {
    
    typealias Dependency = (state: (HomeState) -> Void, events: Signal<HomeState.Event>)
    var dependency: Dependency!
    
    fileprivate typealias Feedback = DriverFeedback<HomeState>
    fileprivate var homeMenuPresenter: HomeMenuPresenter!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPresenter()
        setupRxFeedback()
    }
    
    private func setupPresenter() {
        fabMenuBacking = .fade
        homeMenuPresenter = HomeMenuPresenter(view: view, fabMenu: fabMenu, navigationItem: navigationItem)
    }
    
    private func setupRxFeedback() {
        
        guard let dependency = dependency else { return }
        
        let injectDependncy = self.injectDependncy(appStore: appStore)
        let syncState = self.syncState(dependency: dependency)
        let uiFeedback = self.uiFeedback
        let pickImage = Feedback.pickImage(from: self)
        let saveMedium = Feedback.saveMedium(from: self)
        let queryMedia = Feedback.queryMedia(client: ApolloClient.shared)
//        let showComments = Feedback.showComments(from: self)
//        let showImageDetail = Feedback.showImageDetail(from: self)
        let showUser = Feedback.showUser(from: self)

        let reduce = logger(identifier: "HomeState")(HomeState.reduce)
        
        Driver<Any>.system(
            initialState: HomeState.empty(),
            reduce: reduce,
            feedback:
                injectDependncy,
                syncState,
                uiFeedback,
                pickImage,
                saveMedium,
                queryMedia,
//                showComments,
//                showImageDetail,
                showUser
            )
            .drive()
            .disposed(by: disposeBag)
    }
    
}
extension HomeMenuViewController {
    
    fileprivate func injectDependncy(appStore: AppStore) -> Feedback.Raw {
        return { _ in
            appStore.state.map { $0.currentUser?.toUser() }.asSignal(onErrorJustReturn: nil).map { .onUpdateCurrentUser($0) }
        }
    }
    
    fileprivate func syncState(dependency: Dependency) -> Feedback.Raw {
        return  bind { state in
            return Bindings(
                subscriptions: [state.drive(onNext: dependency.state)],
                events: [dependency.events,]
            )
        }
    }
    
    fileprivate var uiFeedback: Feedback.Raw {
        return bind(homeMenuPresenter) { (presenter, state) in
            let subscriptions = [
                state.map { $0.isFABMenuOpened }.distinctUntilChanged().drive(presenter.isFABMenuOpened),
                state.map { $0.triggerFABMenuClose }.distinctUntilChanged { $0 != nil }.unwrap().drive(presenter.fabMenu.rx.close()),
                
                ]
            let events = [
                presenter.fabMenu.rx.fabMenuWillOpen.map { HomeState.Event.fabMenuWillOpen },
                presenter.fabMenu.rx.fabMenuWillClose.map { HomeState.Event.fabMenuWillClose },
                presenter.cameraFABMenuItem.fabButton.rx.tap.map { HomeState.Event.triggerFABMenuClose },
                presenter.cameraFABMenuItem.fabButton.rx.tap.map { HomeState.Event.triggerPickImage(.camera) },
                presenter.photoFABMenuItem.fabButton.rx.tap.map { HomeState.Event.triggerFABMenuClose },
                presenter.photoFABMenuItem.fabButton.rx.tap.map { HomeState.Event.triggerPickImage(.photoLibrary) },
                ]
            return Bindings(subscriptions: subscriptions, events: events)
        }
    }
}

extension UserObject {
    
    func toUser() -> UserDetailFragment {
        let snapshot = dictionaryWithValues(forKeys: [
            "_id",
            "username",
            "avatarId",
            "followingsCount",
            "followersCount",
            "reputation",
            "gainedReputation",
            "notificationsCount",
            ])
        return UserDetailFragment(snapshot: snapshot)
    }
}
