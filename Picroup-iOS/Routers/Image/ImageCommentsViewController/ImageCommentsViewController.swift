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
    
    typealias Dependency = RankedMediaQuery.Data.RankedMedium.Item
    var dependency: Dependency!
    
    @IBOutlet private var presenter: ImageCommentsPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRxFeedback()
    }
    
    private func setupRxFeedback() {
        
        guard let dependency = dependency else { return }
        typealias Feedback = Observable<Any>.Feedback<ImageCommentsState, ImageCommentsState.Event>
        presenter.setup()
        
        typealias Section = ImageCommentsPresenter.Section
        
        let uiFeedback: Feedback = bind(self) { (me, state) in
            let subscriptions = [
                state.map { $0.medium }.throttle(0.3, scheduler: MainScheduler.instance).bind(to: me.presenter.medium),
                state.map { $0.saveComment.next.content }.bind(to: me.presenter.contentTextField.rx.text),
                state.map { $0.shouldSendComment ? 1 : 0 }.bind(to: me.presenter.sendButton.rx.alpha),
                me.presenter.hideCommentsContentView.rx.tapGesture().when(.recognized).mapToVoid().bind(to: me.rx.pop(animated: true)),
                me.presenter.imageView.rx.tapGesture().when(.recognized).mapToVoid().bind(to: me.rx.pop(animated: true)),
                me.presenter.tableViewBackgroundButton.rx.tap.bind(to: me.rx.pop(animated: true)),
                me.presenter.sendButton.rx.tap.bind(to: me.presenter.contentTextField.rx.resignFirstResponder()),
                state.map { [Section(model: "", items: $0.items)]  }.bind(to: me.presenter.items) ,
                ]
            let events: [Observable<ImageCommentsState.Event>] = [
                state.flatMapLatest {
                    $0.shouldQueryMore ? me.presenter.tableView.rx.isNearBottom.asObservable() : .empty()
                    }.map { .onTriggerGetMore },
                state.flatMapLatest {
                    $0.shouldSendComment ? me.presenter.sendButton.rx.tap.asObservable() : .empty()
                    }.map { .saveComment(.trigger) },
                me.presenter.contentTextField.rx.text.orEmpty.debounce(0.3, scheduler: MainScheduler.instance).distinctUntilChanged().map(ImageCommentsState.Event.onChangeCommentContent)
                ]
            return Bindings(subscriptions: subscriptions, events: events)
        }
        
        let queryMedia: Feedback = react(query: { $0.query }) { (query) in
            ApolloClient.shared.rx.fetch(query: query, cachePolicy: .fetchIgnoringCacheData).map { $0?.data?.medium }.unwrap().asObservable()
                .map(ImageCommentsState.Event.onGetSuccess)
                .catchError { error in .just(.onGetError(error)) }
        }
        
        let saveComment: Feedback = react(query: { $0.saveComment.query }) { query in
            ApolloClient.shared.rx.perform(mutation: query).map { $0?.data?.saveComment }.unwrap().asObservable()
                .map { ImageCommentsState.Event.saveComment(.onSuccess($0)) }
                .catchError { .just(.saveComment(.onError($0))) }
        }
        
        Observable<Any>.system(
            initialState: ImageCommentsState.empty(userId: Config.userId, medium: dependency),
            reduce: logger(identifier: "ImageCommentsState")(ImageCommentsState.reduce),
            scheduler: MainScheduler.instance,
            scheduledFeedback: uiFeedback, queryMedia, saveComment
            )
            .subscribe()
            .disposed(by: disposeBag)
    }
}


