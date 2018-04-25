//
//  MeState+Route.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/23.
//  Copyright © 2018年 luojie. All rights reserved.
//


import UIKit
import Material
import RxSwift
import RxCocoa
import RxFeedback
import Apollo

extension DriverFeedback where State == MeState {

    static func showImageDetail(from vc: UIViewController) -> Raw {
        return react(query: { $0.showImageDetailQuery }) { [weak vc] item in
            let dependency = ImageDetailViewController.Dependency(snapshot: item.snapshot)
            let idvc = RouterService.Image.imageDetailViewController(dependency: dependency)
            vc?.navigationController?.pushViewController(idvc, animated: true)
            return idvc.rx.deallocated.map { .onShowImageDetailCompleted }
                .take(1)
                .asSignalOnErrorRecoverEmpty()
        }
    }
    
    static func showReputations(from vc: UIViewController) -> Raw {
        return react(query: { $0.showReputationsQuery }) { [weak vc] repuation in
            let rvc = RouterService.Main.reputationsViewController(dependency: repuation)
            vc?.navigationController?.pushViewController(rvc, animated: true)
            return rvc.rx.deallocated.map { .onShowReputationsCompleted }
                .take(1)
                .asSignalOnErrorRecoverEmpty()
        }
    }
}



