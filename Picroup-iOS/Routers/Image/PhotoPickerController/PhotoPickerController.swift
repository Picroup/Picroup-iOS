//
//  PhotoPickerController.swift
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
import ImagePicker

final class PhotoPickerController: ImagePickerController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
    }
}

extension PhotoPickerController: ImagePickerDelegate {
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        imagePicker.dismiss(animated: true)
    }
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) { }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        
        let imageKeys = (0..<images.count).map { _ in UUID().uuidString }
        zip(images, imageKeys).forEach { image, key in ImageCache.default.store(image, forKey: key) }
        
        Realm.background(updates: { (realm) in
            guard let route = realm.object(ofType: CreateImageRouteObject.self, forPrimaryKey: PrimaryKey.default) else { return }
            try realm.write {
                route.imageKeys.removeAll()
                route.imageKeys.append(objectsIn: imageKeys)
                route.version = UUID().uuidString
            }
        }, onError: { print($0) })
        
        imagePicker.dismiss(animated: true)
    }
}
