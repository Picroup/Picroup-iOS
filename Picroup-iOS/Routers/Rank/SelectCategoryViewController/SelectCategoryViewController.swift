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
import RxGesture

struct SelectCategoryState: Mutabled {
    var selectedCategoryIndex: Int
}

extension SelectCategoryState {
    
    static func empty(selectedCategory: MediumCategory?) -> SelectCategoryState {
        return SelectCategoryState(
            selectedCategoryIndex: MediumCategory.allCategories.index(where: { $0 == selectedCategory }) ?? 0
        )
    }
    
    static func index(from selectedCategoryIndex: Int) -> Int? {
        let index = selectedCategoryIndex - 1
        return index < 0 ? nil : index
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
                $0.selectedCategoryIndex = index
            }
        }
    }
}


class SelectCategoryViewController: UIViewController {
    
    typealias Dependency = (selectedCategory: MediumCategory?, onSelect: (MediumCategory?) -> Void)
    
    var dependency: Dependency!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    typealias Feedback = (Driver<SelectCategoryState>) -> Signal<SelectCategoryState.Event>

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let uiFeedback: Feedback = bind(self) { (me, state) in
            let eventsTrigger = PublishRelay<SelectCategoryState.Event>()
            let subscriptions = [
                state.map { $0.categoryViewModels }.drive(me.collectionView.rx.items(cellIdentifier: "CategoryCell", cellType: CategoryCell.self)) { index, viewModel, cell in
                    cell.bind(name: viewModel.category?.name ?? "全部", selected: viewModel.selected) {
                        eventsTrigger.accept(.onSelectedCategoryIndex(index))
                    }
                },
                state.map { $0.selectedCategory }.skip(1).delay(0.3).mapToVoid().drive(me.rx.dismiss(animated: true)),
                state.map { $0.selectedCategory }.skip(1).delay(0.3).drive(onNext: me.dependency.onSelect),
                me.view.rx.tapGesture().when(.recognized).mapToVoid().bind(to: me.rx.dismiss(animated: true)),
                ]
            let events = [
                eventsTrigger.asSignal()
            ]
            return Bindings(subscriptions: subscriptions, events: events)
        }
        
        Driver<Any>.system(
            initialState: SelectCategoryState.empty(selectedCategory: dependency.selectedCategory),
            reduce: logger(identifier: "SelectCategoryState")(SelectCategoryState.reduce),
            feedback: uiFeedback
            )
            .drive()
            .disposed(by: disposeBag)
    }
}

extension SelectCategoryState {
    
    var categoryViewModels: [(category: MediumCategory?, selected: Bool)] {
        return MediumCategory.allCategories.enumerated().map { index, category in
            return (category, index == selectedCategoryIndex)
        }
    }
    
    var selectedCategory: MediumCategory? {
        return MediumCategory.allCategories[selectedCategoryIndex]
    }
}
