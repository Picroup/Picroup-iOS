//
//  UIViewController+isViewAppears.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/6/13.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit

extension UIViewController {
    
    public var isViewAppears: Bool {
        return viewIfLoaded?.window != nil
    }
}
