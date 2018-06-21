//
//  PlaceholderTextView.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/6/7.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

open class PlaceholderTextView: UITextView {
    
    @IBInspectable
    open var placeholder: NSString? {
        didSet { setNeedsDisplay()
        }
    }
    
    @IBInspectable
    open var placeholderColor: UIColor = .lightGray {
        didSet { setNeedsDisplay() }
    }
    
    override open var text: String! {
        didSet { setNeedsDisplay() }
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    fileprivate func setup() {
        NotificationCenter.default.rx.notification(.UITextViewTextDidChange, object: self).map { $0.userInfo }
            .subscribe(onNext: { [weak self] _ in
                self?.setNeedsDisplay()
            })
            .disposed(by: disposeBag)
    }
    
    override open func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let placeholder = placeholder, text.isEmpty else { return }
        
        var placeholderAttributes = [NSAttributedStringKey: AnyObject]()
        placeholderAttributes[.font] = font ?? UIFont.systemFont(ofSize: UIFont.systemFontSize)
        placeholderAttributes[.foregroundColor] = placeholderColor
        
        let placeholderRect = rect.insetBy(
            dx: contentInset.left + textContainerInset.left + textContainer.lineFragmentPadding,
            dy: contentInset.top + textContainerInset.top
        )
        placeholder.draw(in: placeholderRect, withAttributes: placeholderAttributes)
    }
}
