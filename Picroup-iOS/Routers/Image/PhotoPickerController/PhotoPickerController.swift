//
//  PhotoPickerProvider.swift
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
import YPImagePicker

private func photoPicker(from vc: UIViewController?, configure: ((inout YPImagePickerConfiguration) -> Void) = { _ in }) -> Signal<[String]> {
    guard let vc = vc else { return .empty() }
    var configuration = YPImagePickerConfiguration()
    configure(&configuration)
    let photoPickerController = YPImagePicker(configuration: configuration)
    let pickedImageKeys = PublishRelay<[String]>()
    photoPickerController.didFinishPicking { [weak photoPickerController] (items, cancel) in
        let images = items.compactMap { item -> UIImage? in
            switch item {
            case .photo(let photo): return photo.image
            default: return nil
            }
        }
        
        let imageKeys = (0..<images.count).map { _ in UUID().uuidString }
        let tasks = zip(images, imageKeys).map { image, key in ImageCache.default.rx.store(image, forKey: key, toDisk: false) }
        _ = Completable.merge(tasks)
            .subscribe(onCompleted: { pickedImageKeys.accept(imageKeys) })
        
        photoPickerController?.dismiss(animated: true)
    }
    vc.present(photoPickerController, animated: true)
    return pickedImageKeys.asSignal()
}

struct PhotoPickerProvider {
    
    static func pickImages(from vc: UIViewController?, imageLimit: Int = 0) -> Signal<[String]> {
        return photoPicker(from: vc) { configuration in
            configuration.library.maxNumberOfItems = imageLimit
            configuration.shouldSaveNewPicturesToAlbum = false
            configuration.startOnScreen = .library
            configuration.screens = [.library, .photo,]
            
            configuration.filters = [
                YPFilterDescriptor(name: "原图", filterName: ""),
                YPFilterDescriptor(name: "瞬间", filterName: "CIPhotoEffectInstant"),
                YPFilterDescriptor(name: "鲜艳", filterName: "CIPhotoEffectChrome"),
                YPFilterDescriptor(name: "打磨", filterName: "CIPhotoEffectProcess"),
                YPFilterDescriptor(name: "转换", filterName: "CIPhotoEffectTransfer"),
                YPFilterDescriptor(name: "褪色", filterName: "CIPhotoEffectFade"),
                YPFilterDescriptor(name: "棕褐色", filterName: "CISepiaTone"),
                YPFilterDescriptor(name: "老电影", filterName: "CIPhotoEffectNoir"),
                YPFilterDescriptor(name: "色质", filterName: "CIPhotoEffectTonal"),
                YPFilterDescriptor(name: "黑白", filterName: "CIPhotoEffectMono"),
            ]
            
            configuration.wordings.ok = "好"
            configuration.wordings.done = "完成"
            configuration.wordings.cancel = "取消"
            configuration.wordings.save = "保存"
            configuration.wordings.processing = "处理中"
            configuration.wordings.trim = "修剪"
            configuration.wordings.cover = "封面"
            configuration.wordings.albumsTitle = "相册"
            configuration.wordings.libraryTitle = "资源"
            configuration.wordings.cameraTitle = "相机"
            configuration.wordings.videoTitle = "视频"
            configuration.wordings.next = "下一步"
            configuration.wordings.filter = "滤镜"
            configuration.wordings.crop = "裁剪"
            configuration.wordings.warningMaxItemsLimit = "最多 %d 张图片"
        }
    }
}
