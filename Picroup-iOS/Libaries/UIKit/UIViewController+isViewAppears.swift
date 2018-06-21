//
//  UIViewController+isViewAppears.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/6/13.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit

//extension UIViewController {
//
//    public var isViewAppears: Bool {
//
//
//        return viewIfLoaded?.window != nil
//    }
//}

class BaseViewController: UIViewController {
    
    var isViewDisappeared = false
    
    var shouldReactQuery: Bool {
        return !isViewDisappeared
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isViewDisappeared = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isViewDisappeared = true
    }
}
