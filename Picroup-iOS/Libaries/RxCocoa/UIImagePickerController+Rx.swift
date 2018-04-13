//
//  UIImagePickerController+Rx.swift
//  RxExample
//
//  Created by Segii Shulga on 1/4/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//



import RxSwift
import RxCocoa
import UIKit

private var imagePickerDelegateKey = "RxImagePickerDelegateProxy"

extension Reactive where Base: UIImagePickerController {
    
    var delegate: RxImagePickerDelegateProxy {
        if let _delegate = objc_getAssociatedObject(base, &imagePickerDelegateKey) as? RxImagePickerDelegateProxy {
            return _delegate
        }
        let _delegate = RxImagePickerDelegateProxy()
        objc_setAssociatedObject(base, &imagePickerDelegateKey, _delegate, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        base.delegate = _delegate
        return _delegate
    }
    
    /**
     Reactive wrapper for `delegate` message.
     */
    public var didFinishPickingMediaWithInfo: ControlEvent<[String : Any]> {
        return ControlEvent(events: delegate._didFinishPickingMediaWithInfo)
    }
    
    /**
     Reactive wrapper for `delegate` message.
     */
    public var didCancel: ControlEvent<()> {
        return ControlEvent(events: delegate._didCancel)
    }
    
}


