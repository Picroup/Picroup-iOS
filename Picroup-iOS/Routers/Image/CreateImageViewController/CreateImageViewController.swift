//
//  CreateImageViewController.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/11.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import Material
import RxSwift
import RxCocoa
import RxFeedback
import Apollo

class CreateImageViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var cancelButton: RaisedButton!
    @IBOutlet weak var saveButton: RaisedButton!
    @IBOutlet weak var progressView: UIProgressView!
    
    var dependency: (image: UIImage, clinet: ApolloClient)?
    private let disposeBag = DisposeBag()
    typealias Feedback = (Driver<CreateImageState>) -> Signal<CreateImageState.Event>
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRxFeedback()
    }
    
    private func setupRxFeedback() {
        
        guard let dependency = dependency else { return }
        guard let snackbarController = snackbarController else { return }
        
        let uiFeedback: Feedback = bind(self) { (me, state) in
            let eventsTrigger = PublishRelay<CreateImageState.Event>()
            let subscriptions = [
                state.map { $0.pickedImage }.drive(me.imageView.rx.image),
                state.map { $0.progress }.map { $0?.completed ?? 0 }.distinctUntilChanged().drive(me.progressView.rx.progress),
                state.map { $0.categoryViewModels }.drive(me.collectionView.rx.items(cellIdentifier: "CategoryCell", cellType: CategoryCell.self)) { index, viewModel, cell in
                    cell.bind(name: viewModel.category.name, selected: viewModel.selected) {
                        eventsTrigger.accept(.onSelectedCategoryIndex(index))
                    }
                    
                },
                state.map { $0.shouldSaveImage }.distinctUntilChanged().drive(me.saveButton.rx.isEnabledWithBackgroundColor(.secondary)),
                state.map { $0.triggerCancel }.distinctUnwrap().drive(me.rx.dismiss(animated: true)),
                state.map { $0.savedMedia }.distinctUnwrap().map { _ in "已保存" }.drive(snackbarController.rx.snackbarText),
                state.map { $0.savedMedia }.distinctUnwrap().mapToVoid().delay(3.3).drive(me.rx.dismiss(animated: true)),
                ]
            let events = [
                eventsTrigger.asSignal(),
                me.cancelButton.rx.tap.asSignal().map { CreateImageState.Event.triggerCancel },
                me.saveButton.rx.tap.asSignal().map { CreateImageState.Event.triggerSave }
            ]
            return Bindings(subscriptions: subscriptions, events: events)
        }
        
        
        let saveMedium: Feedback = react(query: { $0.triggerSave }) { (param) in
            return MediumService.saveMedium(client: dependency.clinet, userId: param.userId, pickedImage: param.pickedImage, category: param.selectedCategory)
                .map { result in
                    switch result {
                    case .progress(let progress):
                        return CreateImageState.Event.onProgress(progress)
                    case .completed(let medium):
                        return CreateImageState.Event.onSavedMedium(medium)
                    }
                }.asSignal(onErrorRecover: { error in .just(.onError(error) )})
        }
        
        let syncLocalStorage: Feedback = bind(LocalStorage.standard) { (localStorage, state) in
            let subscriptions = [
                state.map { MediumCategory.all[$0.selectedCategoryIndex] }.drive(onNext: { localStorage.createImageSelectedCategory = $0 })
            ]
            let events = [
                Signal<CreateImageState.Event>.never()
            ]
            return Bindings(subscriptions: subscriptions, events: events)
        }
        
        Driver<Any>.system(
            initialState: CreateImageState.empty(pickedImage: dependency.image, selectedCategory: LocalStorage.standard.createImageSelectedCategory),
            reduce: logger(identifier: "CreateImageState")(CreateImageState.reduce),
            feedback: uiFeedback, saveMedium, syncLocalStorage
            )
            .drive()
            .disposed(by: disposeBag)
    
    }
}

class CategoryCell: RxCollectionViewCell {
    @IBOutlet weak var button: RaisedButton!
    
    func bind(name: String, selected: Bool, onTap: @escaping () -> Void) {
        button.setTitle(name, for: .normal)
        setSelected(selected)
        bindButtonTap(to: onTap)
    }
    
    private func setSelected(_ selected: Bool) {
        if selected {
            button.titleColor = .primaryText
            button.backgroundColor = .primary
        } else {
            button.titleColor = .primary
            button.backgroundColor = .primaryText
        }
    }
    
    private func bindButtonTap(to onTap: @escaping () -> Void) {
        button.rx.tap
            .subscribe(onNext: onTap)
            .disposed(by: disposeBag)
    }
}

extension CreateImageState {
    
    var categoryViewModels: [(category: MediumCategory, selected: Bool)] {
        return MediumCategory.all.enumerated().map { index, category in
            return (category, index == selectedCategoryIndex)
        }
    }
}


