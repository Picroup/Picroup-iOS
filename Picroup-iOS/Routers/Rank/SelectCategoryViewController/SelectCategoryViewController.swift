//
//  SelectCategoryTableViewController.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/13.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxFeedback

struct SelectCategoryState: Mutabled {
    var selectedCategoryInedx: Int
}

extension SelectCategoryState {
    
    static func empty() -> SelectCategoryState {
        return SelectCategoryState(
            selectedCategoryInedx: 0
        )
    }
}

extension SelectCategoryState: IsFeedbackState {
    enum Event {
        case onSelectedCategoryIndex(Int)
    }
}

extension SelectCategoryState {
    
    static func reduce(state: SelectCategoryState, event: Event) -> SelectCategoryState {
        switch event {
        case .onSelectedCategoryIndex(let index):
            return state.mutated {
                $0.selectedCategoryInedx = index
            }
        }
    }
}


class SelectCategoryViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private let disposeBag = DisposeBag()
    
    typealias Feedback = (Driver<SelectCategoryState>) -> Signal<SelectCategoryState.Event>

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let uiFeedback: Feedback = bind(self) { (me, state) in
            let eventsTrigger = PublishRelay<SelectCategoryState.Event>()
            let subscriptions = [
                state.map { $0.categoryViewModels }.drive(me.collectionView.rx.items(cellIdentifier: "CategoryCell", cellType: CategoryCell.self)) { index, viewModel, cell in
                    cell.bind(category: viewModel.category, selected: viewModel.selected) {
                        eventsTrigger.accept(.onSelectedCategoryIndex(index))
                    }
                },
                state.map { $0.selectedCategoryInedx }.skip(1).delay(0.3).mapToVoid().drive(me.rx.dismiss(animated: true)),
                ]
            let events = [
                eventsTrigger.asSignal()
            ]
            return Bindings(subscriptions: subscriptions, events: events)
        }
        
        Driver<Any>.system(
            initialState: SelectCategoryState.empty(),
            reduce: logger(identifier: "SelectCategoryState")(SelectCategoryState.reduce),
            feedback: uiFeedback
            )
            .drive()
            .disposed(by: disposeBag)
    }
}

extension SelectCategoryState {
    
    var categoryViewModels: [(category: MediumCategory, selected: Bool)] {
        return MediumCategory.all.enumerated().map { index, category in
            return (category, index == selectedCategoryInedx)
        }
    }
}
