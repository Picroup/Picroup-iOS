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

extension PhotoPickerController {
    
    static func pickImages(from vc: UIViewController?, imageLimit: Int = 0) -> Signal<[String]> {
        guard let vc = vc else { return .empty() }
        var configuration = Configuration()
        configuration.managesAudioSession = false
        configuration.OKButtonTitle = "好"
        configuration.cancelButtonTitle = "取消"
        configuration.doneButtonTitle = "下一步"
        configuration.noImagesTitle = "无图片"
        configuration.noCameraTitle = "相机不可用"
        configuration.settingsTitle = "设置"
        configuration.requestPermissionTitle = "无访问权限"
        configuration.requestPermissionMessage = "请允许应用读取图片库"
        let photoPickerController = PhotoPickerController(configuration: configuration)
        photoPickerController.imageLimit = imageLimit
        vc.present(photoPickerController, animated: true)
        return photoPickerController.pickedImageKeys.asSignal()
    }
}

final class PhotoPickerController: ImagePickerController {
    
    fileprivate let pickedImageKeys = PublishRelay<[String]>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
    }
    
    deinit {
        print("PhotoPickerController deinit")
    }
}

extension PhotoPickerController: ImagePickerDelegate {
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        imagePicker.dismiss(animated: true)
    }
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) { }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        
        let imageKeys = (0..<images.count).map { _ in UUID().uuidString }
        let tasks = zip(images, imageKeys).map { image, key in ImageCache.default.rx.store(image, forKey: key, toDisk: false) }
        _ = Completable.merge(tasks)
            .subscribe(onCompleted: { self.pickedImageKeys.accept(imageKeys) })
        
        imagePicker.dismiss(animated: true)
    }
}


