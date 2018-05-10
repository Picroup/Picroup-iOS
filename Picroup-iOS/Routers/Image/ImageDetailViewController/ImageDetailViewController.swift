//
//  ImageDetailViewController.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/16.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import Material
import RxSwift
import RxCocoa
import RxFeedback
import Apollo

fileprivate typealias Section = ImageDetailPresenter.Section
fileprivate typealias CellStyle = ImageDetailPresenter.CellStyle

class ImageDetailViewController: HideNavigationBarViewController {
    
    typealias Dependency = RankedMediaQuery.Data.RankedMedium.Item
    var dependency: Dependency!
    
    @IBOutlet var presenter: ImageDetailPresenter!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupRxFeedback()
    }
    
    private func setupRxFeedback() {
        
        guard let dependency = dependency else { return }
        typealias Feedback = Observable<Any>.Feedback<ImageDetailState, ImageDetailState.Event>

        store.onViewMedium(mediumId: dependency.id)
        
        let injectDependncy: Feedback = { _ in
            store.state.map { $0.currentUser?.toUser() }.asObservable().map { .onUpdateCurrentUser($0) }
        }
        
        let uiFeedback: Feedback = bind(self) { (me, state) in
            let presenter = me.presenter!
            let starMediumTrigger = PublishRelay<Void>()
            let popTrigger = PublishRelay<Void>()
            weak var weakMe = me
            let showImageComments = { (state: ImageDetailState) in {
                let vc = RouterService.Image.imageCommentsViewController(dependency: state.item)
                weakMe?.navigationController?.pushViewController(vc, animated: true)
                }}
            
            let subscriptions = [
                state.map { $0.sections }.throttle(1, scheduler: MainScheduler.instance).bind(to: me.presenter.items(
                    onStarButtonTap: starMediumTrigger.accept,
                    showImageComments: showImageComments,
                    onImageViewTap: popTrigger.accept
                )),
                presenter.backgroundButton.rx.tap.bind(to: popTrigger),
                popTrigger.bind(to: me.rx.pop(animated: true)),
            ]
            let events = [
                state.flatMapLatest { state -> Observable<ImageDetailState.Event>  in
                    guard state.shouldStarMedium else {
                        return .empty()
                    }
                    return starMediumTrigger.map { .onTriggerStarMedium }
                },
                state.flatMapLatest {
                    $0.shouldQueryMore ? presenter.collectionView.rx.isNearBottom.asSignal() : .empty()
                    }.map { .onTriggerGetMore },
            ]
            return Bindings(subscriptions: subscriptions, events: events)
        }
        
        let queryMedium: Feedback = react(query: { $0.query }) { query in
            ApolloClient.shared.rx.fetch(query: query, cachePolicy: .fetchIgnoringCacheData).asObservable()
                .map { $0?.data?.medium }.unwrap()
                .map { .onGetSuccess($0) }
                .catchErrorRecover { .onGetError($0) }
        }

        let starMedium: Feedback = react(query: { $0.starMediumQuery }) { query in
            ApolloClient.shared.rx.perform(mutation: query).asObservable().map { $0?.data?.starMedium }.unwrap()
                .map { .onStarMediumSuccess($0) }
                .catchErrorRecover { .onStarMediumError($0) }
        }
        
        Observable<Any>.system(
            initialState: ImageDetailState.empty(item: dependency),
            reduce: logger(identifier: "ImageDetailState")(ImageDetailState.reduce),
            scheduler: MainScheduler.instance,
            scheduledFeedback:
                injectDependncy,
                uiFeedback,
                queryMedium,
                starMedium
        )
            .subscribe()
            .disposed(by: disposeBag)
        
        presenter.collectionView.rx.modelSelected(CellStyle.self).asSignal()
            .emit(to: Binder(self) { me, cellStyle in
                switch cellStyle {
                case .recommendMedium(let medium):
                    let dependency = ImageDetailViewController.Dependency(snapshot: medium.snapshot)
                    let vc = RouterService.Image.imageDetailViewController(dependency: dependency)
                    me.navigationController?.pushViewController(vc, animated: true)
                default:
                    break
                }
            })
            .disposed(by: disposeBag)

        presenter.collectionView.rx.setDelegate(presenter).disposed(by: disposeBag)
    }
}

extension ImageDetailState {
    
    fileprivate var sections: [Section] {
        let imageDetailItems = [CellStyle.imageDetail(self)]
        let recommendMediaItems = items.map(CellStyle.recommendMedium)
        let imageDetailSection = ImageDetailPresenter.Section(model: "imageDetail", items: imageDetailItems)
        let recommendMediaSection = ImageDetailPresenter.Section(model: "recommendMedia", items: recommendMediaItems)
        return [
            imageDetailSection,
            recommendMediaSection
        ]
    }
}
