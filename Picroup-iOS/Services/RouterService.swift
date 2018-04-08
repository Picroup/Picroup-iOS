//
//  RouterService.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/5.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class RouterService {
    
    let rootViewController: UIViewController
    
    init(rootViewController: UIViewController) {
        self.rootViewController = rootViewController
    }
    
    func showSubState(dependency: @escaping (Driver<SubViewState>) -> Signal<SubViewState.Event>) {
        print("showSubState")
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SubViewController") as! SubViewController
        vc.dependency = dependency
        (rootViewController as? UINavigationController)?.pushViewController(vc, animated: true)
    }
}
