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
            let subscriptions = [
                state.map { $0.pickedImage }.drive(me.imageView.rx.image),
                state.map { $0.progress }.map { $0?.completed ?? 0 }.distinctUntilChanged().drive(me.progressView.rx.progress),
                Driver.just(["流行", "搞笑", "美女", "帅哥", "动物", "摄影", "设计"]).drive(me.collectionView.rx.items(cellIdentifier: "CategoryCell", cellType: CategoryCell.self)) { index, title, cell in
                    cell.button.setTitle(title, for: .normal)
                    if index == 3 {
                        cell.button.titleColor = .primaryText
                        cell.button.backgroundColor = .primary
                    }
                },
                state.map { $0.shouldSaveImage }.distinctUntilChanged().drive(me.saveButton.rx.isEnabledWithBackgroundColor(.secondary)),
                state.map { $0.triggerCancel }.distinctUnwrap().drive(me.rx.dismiss(animated: true)),
                state.map { $0.savedMedia }.distinctUnwrap().map { _ in "已保存" }.drive(snackbarController.rx.snackbarText),
                state.map { $0.savedMedia }.distinctUnwrap().mapToVoid().delay(4).drive(me.rx.dismiss(animated: true)),
                ]
            let events = [
                me.cancelButton.rx.tap.map { CreateImageState.Event.triggerCancel },
                me.saveButton.rx.tap.map { CreateImageState.Event.triggerSave }
            ]
            return Bindings(subscriptions: subscriptions, events: events)
        }
        
        
        let save: Feedback = react(query: { $0.triggerSave }) { (param) in
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
        
        Driver<Any>.system(
            initialState: CreateImageState.empty(pickedImage: dependency.image),
            reduce: logger(identifier: "CreateImageState")(CreateImageState.reduce),
            feedback: uiFeedback, save
            )
            .drive()
            .disposed(by: disposeBag)
    
    }
}

class CategoryCell: UICollectionViewCell {
    @IBOutlet weak var button: RaisedButton!
}


