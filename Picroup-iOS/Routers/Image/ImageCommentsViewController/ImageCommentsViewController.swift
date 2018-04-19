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
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var backgroundButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRxFeedback()
    }
    
    private func setupRxFeedback() {
        
        guard let dependency = dependency else { return }
        typealias Feedback = Observable<Any>.Feedback<ImageCommentsState, ImageCommentsState.Event>
        
        typealias Section = AnimatableSectionModel<String, RankedMediaQuery.Data.RankedMedium.Item>
        typealias DataSource = RxCollectionViewSectionedAnimatedDataSource<Section>
        
        let popTrigger = PublishRelay<Void>()
        let saveCommentTrigger = PublishRelay<Void>()
        let content = PublishRelay<String>()
        
        let dataSource = DataSource(
            configureCell: { dataSource, collectionView, indexPath, item in
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCommentsDetailCell", for: indexPath) as! ImageCommentsDetailCell
                cell.configure(
                    with: item,
                    onImageViewTap:
                    popTrigger.accept,
                    onSendButtonTap: saveCommentTrigger.accept,
                    onChangeConent: content.accept
                )
                return cell
        },
            configureSupplementaryView: { dataSource, collectionView, title, indexPath in
                return UICollectionReusableView()
        })
        
        let uiFeedback: Feedback = bind(self) { (me, state) in
            let subscriptions = [
                state.map { [Section(model: "", items: [$0.medium])] }.throttle(1, scheduler: MainScheduler.instance).bind(to: me.collectionView.rx.items(dataSource: dataSource)),
                me.backgroundButton.rx.tap.bind(to: popTrigger),
                popTrigger.bind(to: me.rx.pop(animated: true)),
                ]
            let events: [Observable<ImageCommentsState.Event>] = [
                state.flatMapLatest {
                    $0.shouldQueryMore ? me.collectionView.rx.isNearBottom.asObservable() : .empty()
                    }.map { .onTriggerGetMore },
                state.flatMapLatest {
                    $0.shouldSendComment ? saveCommentTrigger.asObservable() : .empty()
                    }.map { .saveComment(.trigger) },
                content.debounce(1, scheduler: MainScheduler.instance).distinctUntilChanged().map(ImageCommentsState.Event.onChangeCommentContent)
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


class ImageCommentsDetailCell: RxCollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var lifeBar: UIView!
    @IBOutlet weak var lifeViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var commentsCountLabel: UILabel!
    @IBOutlet weak var starPlaceholderView: UIView!
    @IBOutlet weak var sendButton: FlatButton!
    @IBOutlet weak var contentTextField: UITextField!
    
    func configure(with item: RankedMediaQuery.Data.RankedMedium.Item, onImageViewTap: (() -> Void)?, onSendButtonTap: (() -> Void)?, onChangeConent: ((String) -> Void)?) {
        imageView.setImage(with: item.minioId)
        imageView.motionIdentifier = item.id
        lifeBar.motionIdentifier = "lifeBar_\(item.id)"
        sendButton.motionIdentifier = "starButton_\(item.id)"
        lifeViewWidthConstraint.constant = CGFloat(item.endedAt.sinceNow / 8.0.weeks) * lifeBar.bounds.width
        commentsCountLabel.text = "\(item.commentsCount)条"
        if let onImageViewTap = onImageViewTap {
            imageView.rx.tapGesture().when(.recognized)
                .mapToVoid()
                .subscribe(onNext: onImageViewTap)
                .disposed(by: disposeBag)
        }
        if let onSendButtonTap = onSendButtonTap {
            sendButton.rx.tap
                .subscribe(onNext: onSendButtonTap)
                .disposed(by: disposeBag)
        }
        if let onChangeConent = onChangeConent {
            contentTextField.rx.text.orEmpty
                .subscribe(onNext: onChangeConent)
                .disposed(by: disposeBag)
        }
    }
}

