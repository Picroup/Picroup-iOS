//
//  RxImagePickerDelegateProxy.swift
//  RxExample
//
//  Created by Segii Shulga on 1/4/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//


import RxSwift
import RxCocoa
import UIKit
    
class RxImagePickerDelegateProxy: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    lazy var _didFinishPickingMediaWithInfo = { PublishRelay<[String : Any]>() }()
    lazy var _didCancel = { PublishRelay<Void>() }()
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        _didFinishPickingMediaWithInfo.accept(info)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        _didCancel.accept(())
    }
}



