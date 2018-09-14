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
import RealmSwift

private func mapCommentMoreButtonTapToEvent(sender: UITableView) -> (CommentObject, ImageCommentsStateObject) -> Signal<ImageCommentsStateObject.Event> {
    return { comment, state in
        
        guard state.sessionState?.isLogin == true else {
            return .just(.onTriggerLogin)
        }
        guard let row = state.commentsQueryState?.cursorComments?.items.index(of: comment),
            let cell = sender.cellForRow(at: IndexPath(row: row, section: 0)) as? CommentCell
            else { return .empty() }
        let currentUserId = state.sessionState?.currentUserId
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

final class ImageCommentsViewController: ShowNavigationBarViewController, IsStateViewController {
    
    typealias State = ImageCommentsStateObject
    typealias Event = State.Event
    
    typealias Dependency = String
    var dependency: Dependency!
    
    @IBOutlet private var presenter: ImageCommentsPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.setup(navigationItem: navigationItem)
        setupRxFeedback()
    }
    
    private func setupRxFeedback() {
        
        guard let mediumId = dependency,
            let realm = try? Realm(),
            let state = try? State.create(mediumId: mediumId)(realm) else { return }
        
        state.rxMedium().map { $0 }.bind(to: presenter.medium).disposed(by: disposeBag)

        state.system(
            uiFeedback: uiFeedback,
            shouldQuery: { [weak self] in self?.shouldReactQuery ?? false  },
            queryComments: { query in
                return ApolloClient.shared.rx.fetch(query: query, cachePolicy: .fetchIgnoringCacheData)
                    .map { $0?.data?.medium?.comments.fragments.cursorCommentsFragment }.forceUnwrap()
        },
            saveComment: { query in
                return ApolloClient.shared.rx.perform(mutation: query)
                    .map { $0?.data?.saveComment.fragments.commentFragment }.forceUnwrap()
        },
            deleteComment: { query in
                return ApolloClient.shared.rx.perform(mutation: query)
                    .map { $0?.data?.deleteComment }.forceUnwrap()
        })
            .drive()
            .disposed(by: disposeBag)

    }
    
    var uiFeedback: State.DriverFeedback {
        typealias Section = ImageCommentsPresenter.Section
        return bind(presenter) { (presenter, state) in
            let commentMoreButtonTap = PublishRelay<CommentObject>()
            let subscriptions = [
                state.map { $0.sessionState?.isLogin ?? false }.drive(presenter.sendCommentContentView.rx.isShowed),
                state.map { $0.saveCommentQueryState?.content }.asObservable().take(1).bind(to: presenter.contentTextField.rx.text),
                state.map { $0.saveCommentQueryState?.shouldQuery == true ? 1 : 0 }.drive(presenter.sendButton.rx.alpha),
                presenter.sendButton.rx.tap.bind(to: presenter.contentTextField.rx.resignFirstResponder()),
                presenter.sendButton.rx.tap.map { "" }.bind(to: presenter.contentTextField.rx.text),
                state.map { [Section(model: "", items: $0.commentsItems())]  }
                    .drive(presenter.items(
                        onMoreButtonTap: { commentMoreButtonTap.accept($0) }
                    )),
//                state.map { $0.isMediumDeleted ? 1 : 0 }.drive(presenter.deleteAlertView.rx.alpha),
                state.map { $0.footerState }.drive(onNext: presenter.loadFooterView.on),
                state.map { $0.commentsQueryState?.isEmpty ?? false }.drive(presenter.isCommentsEmpty),
                ]
            
            let events: [Signal<Event>] = [
                .just(.onTriggerReloadComments),
                commentMoreButtonTap.asObservable().withLatestFrom(state) { ($0, $1) }
                    .asSignalOnErrorRecoverEmpty().flatMapLatest(mapCommentMoreButtonTapToEvent(sender: presenter.tableView)),
                state.flatMapLatest {
                    ($0.commentsQueryState?.shouldQueryMore ?? false)
                        ? presenter.tableView.rx.triggerGetMore
                        : .empty()
                    }.map { .onTriggerGetMoreComments },
                presenter.sendButton.rx.tap.asSignal().map { .onTriggerSaveComment },
                presenter.contentTextField.rx.text.orEmpty.asSignalOnErrorRecoverEmpty()
                    .debounce(0.3).distinctUntilChanged().map(Event.onChangeCommentContent),
                presenter.hideCommentsContentView.rx.tapGesture().when(.recognized).asSignalOnErrorRecoverEmpty().map { _ in .onTriggerPop },
                presenter.imageView.rx.tapGesture().when(.recognized).asSignalOnErrorRecoverEmpty().map { _ in .onTriggerPop },
                presenter.tableViewBackgroundButton.rx.tap.asSignal().map { _ in .onTriggerPop },
                presenter.deleteAlertView.rx.tapGesture().when(.recognized).asSignalOnErrorRecoverEmpty().map { _ in .onTriggerPop },
                ]
            return Bindings(subscriptions: subscriptions, events: events)
        }
    }
}

extension ImageCommentsStateObject {
    
    var footerState: LoadFooterViewState {
        return LoadFooterViewState.create(
            cursor: commentsQueryState?.cursorComments?.cursor.value,
            items: commentsQueryState?.cursorComments?.items,
            trigger: commentsQueryState?.trigger ?? false,
            error: commentsQueryState?.error
        )
    }
    
    func rxMedium() -> Observable<MediumObject> {
        guard let medium = medium else { return .empty() }
        return Observable.from(object: medium).catchErrorRecoverEmpty()
    }
    
    func commentsItems() -> [CommentObject] {
        return commentsQueryState?.cursorComments?.items.toArray() ?? []
    }
}


