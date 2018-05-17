//
//  ImagePickerController.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/17.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RealmSwift
import Kingfisher

final class ImagePickerController: UIImagePickerController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rx.didFinishPickingMediaWithInfo.asSignal()
            .map { info in
                return info[UIImagePickerControllerOriginalImage] as? UIImage
            }.unwrap()
            .emit(to: onPickImage())
            .disposed(by: disposeBag)
        
        rx.didCancel.asSignal()
            .emit(to: rx.dismiss(animated: true))
            .disposed(by: disposeBag)
    }
    
    func onPickImage() -> Binder<UIImage> {
        return Binder(self) { me, image in
            let key = UUID().uuidString
            ImageCache.default.store(image, forKey: key)
            
            Realm.background(updates: { (realm) in
                guard let route = realm.object(ofType: CreateImageRouteObject.self, forPrimaryKey: Config.realmDefaultPrimaryKey) else { return }
                try realm.write {
                    route.imageKey = key
                    route.version = UUID().uuidString
                }
            }, onError: { print($0) })
            
            me.presentingViewController?.dismiss(animated: true)
        }
    }
}
