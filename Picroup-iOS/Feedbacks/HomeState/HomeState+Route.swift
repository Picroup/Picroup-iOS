//
//  HomeState+Route.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/22.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import Material
import RxSwift
import RxCocoa
import RxFeedback
import Apollo

extension DriverFeedback where State == HomeState {
    
    static func pickImage(from vc: UIViewController) -> Raw {
        return react(query: { $0.triggerPickImage }) { [weak vc] sourceType  in
            let rxPicker = UIImagePickerController.rx.createWithParent(vc) {
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
                .asSignalOnErrorRecoverEmpty()
        }
    }
    
    static func saveMedium(from vc: UIViewController) -> Raw {
        return react(query: { $0.saveMediumQuery }) { [weak vc] image in
            let civc = RouterService.Main.createImageViewController(dependency: (image, ApolloClient.shared))
            vc?.present(SnackbarController(rootViewController: civc), animated: true, completion: nil)
            let saved = civc.savedMedium.map(HomeState.Event.onSeveMediumSuccess).asObservable()
            let canceled = civc.rx.deallocated.map { HomeState.Event.onSeveMediumCancelled }
            return Observable.merge(saved, canceled)
                .take(1)
                .asSignalOnErrorRecoverEmpty()
        }
    }
    
    static func showComments(from vc: UIViewController) -> Raw {
        return react(query: { $0.showCommentsQuery }) { [weak vc] item in
            let dependency = ImageCommentsViewController.Dependency(snapshot: item.snapshot)
            let icvc = RouterService.Main.imageCommentsViewController(dependency: dependency)
            vc?.navigationController?.pushViewController(icvc, animated: true)
            return icvc.rx.deallocated.map { HomeState.Event.onShowCommentsCompleted }
                .take(1)
                .asSignalOnErrorRecoverEmpty()
        }
    }
    
    static func showImageDetail(from vc: UIViewController) -> Raw {
        return react(query: { $0.showImageDetailQuery }) { [weak vc] item in
            let dependency = ImageDetailViewController.Dependency(snapshot: item.snapshot)
            let idvc = RouterService.Main.imageDetailViewController(dependency: dependency)
            vc?.navigationController?.pushViewController(idvc, animated: true)
            return idvc.rx.deallocated.map { HomeState.Event.onShowImageDetailCompleted }
                .take(1)
                .asSignalOnErrorRecoverEmpty()
        }
    }
}


