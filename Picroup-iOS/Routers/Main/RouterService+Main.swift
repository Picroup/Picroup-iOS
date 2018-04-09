//
//  RouterService+Main.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/9.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Apollo

extension RouterService {
    
    enum Main {}
}

extension RouterService.Main {
    
    static func mainViewController() -> UIViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()!
        return vc
    }
    
}

