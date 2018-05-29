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
                state.map { $0.session?.isLogin ?? false }.drive(presenter.sendCommentContentView.rx.isShowed),
                state.map { $0.saveCommentContent }.drive(presenter.contentTextField.rx.text),
                state.map { $0.shouldSendComment ? 1 : 0 }.drive(presenter.sendButton.rx.alpha),
                presenter.sendButton.rx.tap.bind(to: presenter.contentTextField.rx.resignFirstResponder()),
                store.commentsItems().map { [Section(model: "", items: $0)]  }.drive(presenter.items),
                state.map { $0.footerState }.drive(onNext: presenter.loadFooterView.on),
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
            .debug("ImageCommentsState.Event", trimOutput: true)
            .emit(onNext: store.on)
            .disposed(by: disposeBag)
    }
}

extension ImageCommentsStateObject {
    
    var footerState: LoadFooterViewState {
        let (cursor, trigger, error) = (comments?.cursor.value, triggerCommentsQuery, commentsError)
        return LoadFooterViewState.create(cursor: cursor, trigger: trigger, error: error)
    }
}


