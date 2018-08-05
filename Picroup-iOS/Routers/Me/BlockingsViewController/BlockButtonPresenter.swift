//
//  BlockButtonPresenter.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/8/3.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Material

struct BlockButtonPresenter {
    
    static func isSelected(base: RaisedButton) -> Binder<Bool?> {
        return Binder(base) { button, isSelected in
            //            UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseInOut, animations: {
            guard let isSelected = isSelected else {
                button.alpha = 0
                return
            }
            button.alpha =  1
            if !isSelected {
                button.backgroundColor = .primaryText
                button.titleColor = .secondary
                button.setTitle("拉黑", for: .normal)
            } else {
                button.backgroundColor = .secondary
                button.titleColor = .primaryText
                button.setTitle("取消拉黑", for: .normal)
            }
            //            })
        }
    }
}
