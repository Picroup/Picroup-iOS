//
//  ImageCommentsViewController.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/19.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import Material
import RxSwift
import RxCocoa
import RxFeedback
import RxDataSources
import Apollo

class ImageCommentsViewController: HideNavigationBarViewController {
    
    typealias Dependency = String
    var dependency: Dependency!
    
    fileprivate typealias Feedback = (Driver<ImageCommentsStateObject>) -> Signal<ImageCommentsStateObject.Event>
    @IBOutlet private var presenter: ImageCommentsPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRxFeedback()
    }
    
    private func setupRxFeedback() {
        
        guard
            let mediumId = dependency,
            let store = try? ImageCommentsStateStore(mediumId: mediumId)
            else {
                return
        }
        
        presenter.setup()
        
        typealias Section = ImageCommentsPresenter.Section
        let uiFeedback: Feedback = bind(presenter) { (presenter, state) in
            
            let subscriptions = [
                store.medium().drive(presenter.medium),
                state.map { $0.saveCommentContent }.drive(presenter.contentTextField.rx.text),
                state.map { $0.shouldSendComment ? 1 : 0 }.drive(presenter.sendButton.rx.alpha),
                presenter.sendButton.rx.tap.bind(to: presenter.contentTextField.rx.resignFirstResponder()),
                store.commentsItems().map { [Section(model: "", items: $0)]  }.drive(presenter.items),
                ]
            let events: [Signal<ImageCommentsStateObject.Event>] = [
                .just(.onTriggerReloadData),
                state.flatMapLatest {
                    $0.shouldQueryMoreComments
                        ? presenter.tableView.rx.triggerGetMore
                        : .empty()
                    }.map { .onTriggerGetMoreData },
                presenter.sendButton.rx.tap.asSignal().map { .onTriggerSaveComment },
                presenter.contentTextField.rx.text.orEmpty.asSignalOnErrorRecoverEmpty()
                    .debounce(0.3).distinctUntilChanged().map(ImageCommentsStateObject.Event.onChangeCommentContent),
                presenter.hideCommentsContentView.rx.tapGesture().when(.recognized).asSignalOnErrorRecoverEmpty().map { _ in .onTriggerPop },
                presenter.imageView.rx.tapGesture().when(.recognized).asSignalOnErrorRecoverEmpty().map { _ in .onTriggerPop },
                presenter.tableViewBackgroundButton.rx.tap.asSignal().map { _ in .onTriggerPop },
            ]
            return Bindings(subscriptions: subscriptions, events: events)
        }
        
        let queryComments: Feedback = react(query: { $0.commentsQuery }) { (query) in
            ApolloClient.shared.rx.fetch(query: query, cachePolicy: .fetchIgnoringCacheData)
                .map { $0?.data?.medium?.comments.fragments.cursorCommentsFragment }.unwrap()
                .map(ImageCommentsStateObject.Event.onGetData(isReload: query.cursor == nil))
                .asSignal(onErrorReturnJust: ImageCommentsStateObject.Event.onGetDataError)
        }
        
        let saveComment: Feedback = react(query: { $0.saveCommentQuery }) { query in
            ApolloClient.shared.rx.perform(mutation: query)
                .map { $0?.data?.saveComment.fragments.commentFragment }.unwrap()
                .map(ImageCommentsStateObject.Event.onSaveCommentSuccess)
                .asSignal(onErrorReturnJust: ImageCommentsStateObject.Event.onSaveCommentError)
        }
        
        let states = store.states
        
        Signal.merge(
            uiFeedback(states),
            queryComments(states),
            saveComment(states)
            )
            .debug("ImageCommentsStateObject.Event", trimOutput: true)
            .emit(onNext: store.on)
            .disposed(by: disposeBag)
        
//        guard let dependency = dependency else { return }
//        presenter.setup()
//
//        typealias Section = ImageCommentsPresenter.Section
//
//        let injectDependncy: Feedback = { _ in
//            appStore.state.map { $0.currentUser?.toUser() }.asObservable().map { .onUpdateCurrentUser($0) }
//        }
//
//        weak var weakSelf = self
//        let uiFeedback: Feedback = bind(presenter) { (presenter, state) in
//            let subscriptions = [
//                state.map { $0.medium }.throttle(0.3, scheduler: MainScheduler.instance).bind(to: presenter.medium),
//                state.map { $0.nextSaveComment.content }.bind(to: presenter.contentTextField.rx.text),
//                state.map { $0.shouldSendComment ? 1 : 0 }.bind(to: presenter.sendButton.rx.alpha),
//                presenter.hideCommentsContentView.rx.tapGesture().when(.recognized).mapToVoid().bind(to: weakSelf!.rx.pop(animated: true)),
//                presenter.imageView.rx.tapGesture().when(.recognized).mapToVoid().bind(to: weakSelf!.rx.pop(animated: true)),
//                presenter.tableViewBackgroundButton.rx.tap.bind(to: weakSelf!.rx.pop(animated: true)),
//                presenter.sendButton.rx.tap.bind(to: presenter.contentTextField.rx.resignFirstResponder()),
//                state.map { [Section(model: "", items: $0.items)]  }.bind(to: presenter.items) ,
//                ]
//            let events: [Observable<ImageCommentsState.Event>] = [
//                state.flatMapLatest {
//                    $0.shouldQueryMore ? presenter.tableView.rx.isNearBottom.asObservable() : .empty()
//                    }.map { .onTriggerGetMore },
//                state.flatMapLatest {
//                    $0.shouldSendComment ? presenter.sendButton.rx.tap.asObservable() : .empty()
//                    }.map { .onTriggerSaveComment },
//                presenter.contentTextField.rx.text.orEmpty.debounce(0.3, scheduler: MainScheduler.instance).distinctUntilChanged().map(ImageCommentsState.Event.onChangeCommentContent)
//                ]
//            return Bindings(subscriptions: subscriptions, events: events)
//        }
//
//        let queryMedia: Feedback = react(query: { $0.query }) { (query) in
//            ApolloClient.shared.rx.fetch(query: query, cachePolicy: .fetchIgnoringCacheData)
//                .map { $0?.data?.medium?.comments.fragments.cursorCommentsFragment }.unwrap().asObservable()
//                .map(ImageCommentsState.Event.onGetSuccess)
//                .catchError { error in .just(.onGetError(error)) }
//        }
//
//        let saveComment: Feedback = react(query: { $0.saveCommentQuery }) { query in
//            ApolloClient.shared.rx.perform(mutation: query)
//                .map { $0?.data?.saveComment.fragments.commentFragment }.unwrap().asObservable()
//                .map { .onSaveCommentSuccess($0) }
//                .catchErrorRecover { .onSaveCommentError($0) }
//        }
//
//        Observable<Any>.system(
//            initialState: ImageCommentsState.empty(medium: dependency),
//            reduce: logger(identifier: "ImageCommentsState")(ImageCommentsState.reduce),
//            scheduler: MainScheduler.instance,
//            scheduledFeedback:
//                injectDependncy,
//                uiFeedback,
//                queryMedia,
//                saveComment
//            )
//            .subscribe()
//            .disposed(by: disposeBag)
    }
}


