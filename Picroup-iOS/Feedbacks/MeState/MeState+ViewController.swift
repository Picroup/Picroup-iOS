//
//  MeState+ViewController.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/24.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import Material
import RxSwift
import RxCocoa
import RxFeedback
import RxViewController
import Apollo

extension DriverFeedback where State == MeState {

    static func triggerReloadMe(from vc: UIViewController) -> Raw {
        return { [weak vc] state in
            guard let vc = vc else { return .empty() }
            return vc.rx.viewWillAppear.asSignal().map { _ in .onTriggerReloadMe }
        }
    }
}
