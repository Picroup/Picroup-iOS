//
//  UIView+IBInspectable.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/20.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit

extension UIView {
    
    @IBInspectable
    public var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = true
        }
    }
    
    @IBInspectable
    public var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    public var borderColor: UIColor? {
        get {
            return layer.borderColor?.uiColor
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
}

extension CGColor {
    
    public var uiColor: UIColor {
        
        return UIColor(cgColor: self)
    }
}
