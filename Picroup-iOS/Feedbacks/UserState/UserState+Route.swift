//
//  UserState+Route.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/11.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import Material
import RxSwift
import RxCocoa
import RxFeedback

extension DriverFeedback where State == UserState {
    
//    static func showImageDetail(from vc: UIViewController) -> Raw {
//        return react(query: { $0.showImageDetailQuery }) { [weak vc] item in
//            let idvc = RouterService.Image.imageDetailViewController(dependency: item)
//            vc?.navigationController?.pushViewController(idvc, animated: true)
//            return idvc.rx.deallocated.map { .onShowImageDetailCompleted }
//                .take(1)
//                .asSignalOnErrorRecoverEmpty()
//        }
//    }
    
    static func pop(from vc: UIViewController) -> Raw {
        return react(query: { $0.popQuery }) { [weak vc] _ in
            vc?.navigationController?.popViewController(animated: true)
            return .empty()
        }
    }
}




