//
//  HomeViewController.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/9.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import Material
import RxSwift
import RxCocoa
import RxFeedback
import Apollo

class HomeMenuViewController: FABMenuController {
    
    init() {
        super.init(rootViewController: HomeViewController())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate var homeMenuPresenter: HomeMenuPresenter!
    private let disposeBag = DisposeBag()
    typealias Feedback = (Driver<HomeState>) -> Signal<HomeState.Event>

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPresenter()
        setupRxFeedback()
    }
    
    private func setupPresenter() {
        fabMenuBacking = .fade
        homeMenuPresenter = HomeMenuPresenter(view: view, fabMenu: fabMenu)
    }
    
    private func setupRxFeedback() {
        
        let uiFeedback: Feedback = bind(homeMenuPresenter) { (presenter, state) in
            let subscriptions = [
                state.map { $0.isFABMenuOpened }.distinctUntilChanged().drive(presenter.isFABMenuOpened),
                state.map { $0.triggerFABMenuClose }.distinctUntilChanged { $0 != nil }.unwrap().drive(presenter.fabMenu.rx.close()),
                
                ]
            let events = [
                presenter.fabMenu.rx.fabMenuWillOpen.map { HomeState.Event.fabMenuWillOpen },
                presenter.fabMenu.rx.fabMenuWillClose.map { HomeState.Event.fabMenuWillClose },
                presenter.cameraFABMenuItem.fabButton.rx.tap.map { HomeState.Event.triggerFABMenuClose },
                presenter.cameraFABMenuItem.fabButton.rx.tap.map { HomeState.Event.triggerPickImage(.camera) },
                presenter.photoFABMenuItem.fabButton.rx.tap.map { HomeState.Event.triggerFABMenuClose },
                presenter.photoFABMenuItem.fabButton.rx.tap.map { HomeState.Event.triggerPickImage(.photoLibrary) },
                ]
            return Bindings(subscriptions: subscriptions, events: events)
        }
        
        let pickImage: Feedback = react(query: { $0.triggerPickImage }) { [weak self] (sourceType)  in
            let rxPicker = UIImagePickerController.rx.createWithParent(self) {
                $0.sourceType = sourceType
                }
                .share(replay: 1)
            
            let picked = rxPicker.flatMap {
                $0.rx.didFinishPickingMediaWithInfo
                }
                .map { info in
                    return info[UIImagePickerControllerOriginalImage] as? UIImage
                }.unwrap()
                .map { HomeState.Event.pickedImage($0) }
            
            let cancelled = rxPicker.flatMap {
                $0.rx.didCancel
                }
                .map { _ in HomeState.Event.pickeImageCancelled }
            
            return Observable.merge(picked, cancelled)
                .take(1)
                .asSignal(onErrorRecover: { _ in .empty() })
        }
        
        let addImage: Feedback =  react(query: { $0.pickedImage }) { [weak self] (image) in
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CreateImageViewController") as! CreateImageViewController
            vc.dependency = (image, ApolloClient.shared)
            self?.present(SnackbarController(rootViewController: vc), animated: true, completion: nil)
            return .empty()
        }
        
        Driver<Any>.system(
            initialState: HomeState.empty,
            reduce: logger(identifier: "HomeState")(HomeState.reduce),
            feedback: uiFeedback, pickImage, addImage
            )
            .drive()
            .disposed(by: disposeBag)
    }
}
