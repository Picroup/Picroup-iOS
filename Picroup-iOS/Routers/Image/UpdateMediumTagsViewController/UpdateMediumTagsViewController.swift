//
//  UpdateMediumTagsViewController.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/7/11.
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

final class UpdateMediumTagsViewController: ShowNavigationBarViewController, IsStateViewController {
    
    typealias State = UpdateMediumTagsStateObject
    typealias Event = State.Event
    
    typealias Dependency = String
    var dependency: Dependency?
    
    @IBOutlet fileprivate var presenter: UpdateMediumTagsPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRxFeedback()
    }
    
    private func setupRxFeedback() {
        
        guard let mediumId = dependency,
            let realm = try? Realm(),
            let state = try? State.create(mediumId: mediumId)(realm) else { return }
        
        state.system(
            uiFeedback: uiFeedback,
            shouldQuery: { [weak self] in self?.shouldReactQuery ?? false  },
            addTag: { query in
                return ApolloClient.shared.rx.fetch(query: query, cachePolicy: .fetchIgnoringCacheData)
                    .map { $0?.data?.medium?.addTag.fragments.mediumFragment }.forceUnwrap()
        },
            remeveTag: { query in
                return ApolloClient.shared.rx.fetch(query: query, cachePolicy: .fetchIgnoringCacheData)
                    .map { $0?.data?.medium?.removeTag.fragments.mediumFragment }.forceUnwrap()
        })
            .drive()
            .disposed(by: disposeBag)
        
    }
    
    var uiFeedback: State.DriverFeedback {
        return bind(self) { (me, state) in
            let presenter = me.presenter!
            let subscriptions = [
                state.map { $0.tagStates() }.drive(presenter.tagsCollectionView.rx.items(cellIdentifier: "TagCollectionViewCell", cellType: TagCollectionViewCell.self)) { index, tagState, cell in
                    cell.tagLabel.text = tagState.tag
                    cell.setSelected(tagState.isSelected)
                },
                ]
            let events: [Signal<Event>] = [
                presenter.tagsCollectionView.rx.modelSelected(TagStateObject.self).asSignal().map { .onToggleTag($0.tag) },
                presenter.didCommitTag.asSignal().map(Event.onAddTag),
            ]
            return Bindings(subscriptions: subscriptions, events: events)
        }
    }
}

extension UpdateMediumTagsStateObject {
    func tagStates() -> [TagStateObject] {
        return tagsState?.tagStates.toArray() ?? []
    }
}

