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

private func mapCommentMoreButtonTapToEvent(sender: UITableView) -> (CommentObject, ImageCommentsStateObject) -> Signal<ImageCommentsStateObject.Event> {
    return { comment, state in
        
        guard let row = state.comments?.items.index(of: comment),
            let cell = sender.cellForRow(at: IndexPath(row: row, section: 0)) as? CommentCell
            else { return .empty() }
        let currentUserId = state.session?.currentUser?._id
        let byMe = comment.userId == currentUserId
        let actions = byMe ? ["删除"] : ["举报"]
        return DefaultWireframe.shared
            .promptFor(sender: cell.moreButton, cancelAction: "取消", actions: actions)
            .asSignalOnErrorRecoverEmpty()
            .flatMap { action in
                switch action {
                case "举报":     return .just(.onTriggerCommentFeedback(comment._id))
                case "删除":     return .just(.onTriggerDeleteComment(comment._id))
                default:        return .empty()
                }
        }
    }
}

class ImageCommentsViewController: ShowNavigationBarViewController {
    
    typealias Dependency = String
    var dependency: Dependency!
    
    fileprivate typealias Feedback = (Driver<ImageCommentsStateObject>) -> Signal<ImageCommentsStateObject.Event>
    @IBOutlet private var presenter: ImageCommentsPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRxFeedback()
    }
    
    private func setupRxFeedback() {
        
        guard let mediumId = dependency,
            let store = try? ImageCommentsStateStore(mediumId: mediumId)
            else { return }
        
        presenter.setup()
        
        typealias Section = ImageCommentsPresenter.Section
        let uiFeedback: Feedback = bind(presenter) { (presenter, state) in
            
            let commentMoreButtonTap = PublishRelay<CommentObject>()
            let subscriptions = [
                store.medium().drive(presenter.medium),
                state.map { $0.session?.isLogin ?? false }.drive(presenter.sendCommentContentView.rx.isShowed),
                state.map { $0.saveCommentContent }.asObservable().take(1).bind(to: presenter.contentTextField.rx.text),
                state.map { $0.shouldSendComment ? 1 : 0 }.drive(presenter.sendButton.rx.alpha),
                presenter.sendButton.rx.tap.bind(to: presenter.contentTextField.rx.resignFirstResponder()),
                presenter.sendButton.rx.tap.map { "" }.bind(to: presenter.contentTextField.rx.text),
                store.commentsItems().map { [Section(model: "", items: $0)]  }
                    .drive(presenter.items(
                        onMoreButtonTap: { commentMoreButtonTap.accept($0) }
                    )),
                state.map { $0.isMediumDeleted ? 1 : 0 }.drive(presenter.deleteAlertView.rx.alpha),
                state.map { $0.footerState }.drive(onNext: presenter.loadFooterView.on),
                state.map { $0.isCommentsEmpty }.drive(presenter.isCommentsEmpty),
                ]
            
            
            let events: [Signal<ImageCommentsStateObject.Event>] = [
                .just(.onTriggerReloadData),
                commentMoreButtonTap.asObservable().withLatestFrom(state) { ($0, $1) }
                    .asSignalOnErrorRecoverEmpty().flatMapLatest(mapCommentMoreButtonTapToEvent(sender: presenter.tableView)),
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
                presenter.deleteAlertView.rx.tapGesture().when(.recognized).asSignalOnErrorRecoverEmpty().map { _ in .onTriggerPop },
                ]
            return Bindings(subscriptions: subscriptions, events: events)
        }
        
        let queryComments: Feedback = react(query: { $0.commentsQuery }, effects: composeEffects(shouldQuery: { [weak self] in self?.shouldReactQuery ?? false  }) { (query) in
            ApolloClient.shared.rx.fetch(query: query, cachePolicy: .fetchIgnoringCacheData)
                .map { $0?.data?.medium?.comments.fragments.cursorCommentsFragment }
                .map(ImageCommentsStateObject.Event.onGetData(isReload: query.cursor == nil))
                .asSignal(onErrorReturnJust: ImageCommentsStateObject.Event.onGetDataError)
        })
        
        let saveComment: Feedback = react(query: { $0.saveCommentQuery }, effects: composeEffects(shouldQuery: { [weak self] in self?.shouldReactQuery ?? false  }) { query in
            ApolloClient.shared.rx.perform(mutation: query)
                .map { $0?.data?.saveComment.fragments.commentFragment }.unwrap()
                .map(ImageCommentsStateObject.Event.onSaveCommentSuccess)
                .asSignal(onErrorReturnJust: ImageCommentsStateObject.Event.onSaveCommentError)
        })
        
        let deleteComment: Feedback = react(query: { $0.deleteCommentQuery }, effects: composeEffects(shouldQuery: { [weak self] in self?.shouldReactQuery ?? false  }) { query in
            ApolloClient.shared.rx.perform(mutation: query)
                .map { $0?.data?.deleteComment }.unwrap()
                .map(ImageCommentsStateObject.Event.onDeleteCommentSuccess)
                .asSignal(onErrorReturnJust: ImageCommentsStateObject.Event.onDeleteCommentError)
        })
        
        let states = store.states
        
        Signal.merge(
            uiFeedback(states),
            queryComments(states),
            saveComment(states),
            deleteComment(states)
            )
            .debug("ImageCommentsState.Event", trimOutput: true)
            .emit(onNext: store.on)
            .disposed(by: disposeBag)
    }
}

extension ImageCommentsStateObject {
    
    var footerState: LoadFooterViewState {
        return LoadFooterViewState.create(
            cursor: comments?.cursor.value,
            items: comments?.items,
            trigger: triggerCommentsQuery,
            error: commentsError
        )
    }
}


