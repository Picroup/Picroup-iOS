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
import AVKit

private func photoPicker(from vc: UIViewController?, configure: ((inout YPImagePickerConfiguration) -> Void) = { _ in }) -> Signal<[MediumItem]> {
    guard let vc = vc else { return .empty() }
    var configuration = YPImagePickerConfiguration()
    configure(&configuration)
    let photoPickerController = YPImagePicker(configuration: configuration)
    let pickedItems = PublishRelay<[MediumItem]>()
    photoPickerController.didFinishPicking { [weak photoPickerController] (items, cancel) in
        photoPickerController?.dismiss(animated: true)
        if cancel { return }
        _ = Observable.zip(items.map { $0.mediaItem.asObservable() })
            .take(1)
            .subscribe(onNext: pickedItems.accept)
    }
    vc.present(photoPickerController, animated: true)
    return pickedItems.asSignal()
}

struct PhotoPickerProvider {
    
    static func pickImage(from vc: UIViewController?) -> Signal<String> {
        return _pickMedia(from: vc) { configuration in
            configuration.library.maxNumberOfItems = 1
            configuration.shouldSaveNewPicturesToAlbum = false
            configuration.startOnScreen = .library
            configuration.screens = [.library, .photo,]
            }.flatMap {
                if case .some(.image(let imageKey)) = $0.first {
                    return .just(imageKey)
                }
                return .empty()
        }
    }
    
    static func pickMedia(from vc: UIViewController?) -> Signal<[MediumItem]> {
        return _pickMedia(from: vc) { configuration in
            configuration.library.maxNumberOfItems = Config.maxUploadsCount
            configuration.shouldSaveNewPicturesToAlbum = false

            configuration.video.compression = AVAssetExportPresetMediumQuality
            configuration.video.fileType = .mp4
            configuration.video.recordingTimeLimit = 15
            configuration.video.minimumTimeLimit = 0
            configuration.video.libraryTimeLimit = 20.5
            configuration.video.trimmerMinDuration = 0
            configuration.video.trimmerMaxDuration = 15

            configuration.library.mediaType = .photoAndVideo
            configuration.startOnScreen = .library
            configuration.screens = [.library, .photo, .video]
        }
    }
    
    private static func _pickMedia(from vc: UIViewController?, configure: ((inout YPImagePickerConfiguration) -> Void)) -> Signal<[MediumItem]> {
        return photoPicker(from: vc) { configuration in
            
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
            
            configuration.hidesStatusBar = true
            configuration.colors.tintColor = .primary
            configuration.colors.progressBarCompletedColor = .primary

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
            configuration.wordings.warningMaxItemsLimit = "最多 %d 个"
            
            configuration.wordings.videoDurationPopup.title = "视频时长"
            configuration.wordings.videoDurationPopup.tooLongMessage = "最多 %@ 秒"
            configuration.wordings.videoDurationPopup.tooShortMessage = "至少 %@ 秒"

            configuration.wordings.permissionPopup.title = "无访问权限"
            configuration.wordings.permissionPopup.message = "请授权访问"
            configuration.wordings.permissionPopup.cancel = "取消"
            configuration.wordings.permissionPopup.grantPermission = "授权"
            
            configure(&configuration)
        }
    }
}

enum MediumItem {
    case image(String)
    case video(thumbnailImageKey: String, videoFileURL: URL)
}

extension YPMediaItem {

    var mediaItem: Single<MediumItem> {
        return Single.create { observer in
            switch self {
            case .photo(let photo):
                let imageKey = UUID().uuidString
                ImageCache.default.store(photo.image, forKey: imageKey, toDisk: true) {
                    observer(.success(.image(imageKey)))
                }
            case .video(let video):
                let thumbnailImageKey = UUID().uuidString
                ImageCache.default.store(video.thumbnail, forKey: thumbnailImageKey, toDisk: true) {
                    observer(.success(.video(thumbnailImageKey: thumbnailImageKey, videoFileURL: video.url)))
                }
            }
            return Disposables.create()
        }
    }
}
