//
//  RouterService+Image.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/23.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Apollo
import Material
import ImagePicker

extension RouterService {
    
    enum Image {}
}
extension RouterService.Image {
    
//    static func photoPickerController() -> PhotoPickerController {
//        var configuration = Configuration()
//        configuration.managesAudioSession = false
//        configuration.OKButtonTitle = "好"
//        configuration.cancelButtonTitle = "取消"
//        configuration.doneButtonTitle = "下一步"
//        configuration.noImagesTitle = "无图片"
//        configuration.noCameraTitle = "相机不可用"
//        configuration.settingsTitle = "设置"
//        configuration.requestPermissionTitle = "无访问权限"
//        configuration.requestPermissionMessage = "请允许应用读取图片库"
//        let vc = PhotoPickerController(configuration: configuration)
//        vc.imageLimit = 10
//        return vc
//    }
    
    static func createImageViewController(dependency: CreateImageViewController.Dependency) -> CreateImageViewController {
        let vc = UIStoryboard(name: "Image", bundle: nil).instantiateViewController(withIdentifier: "CreateImageViewController") as! CreateImageViewController
        vc.dependency = dependency
        return vc
    }
    
    static func imageDetailViewController(dependency: ImageDetailViewController.Dependency) -> ImageDetailViewController {
        let vc = UIStoryboard(name: "Image", bundle: nil).instantiateViewController(withIdentifier: "ImageDetailViewController") as! ImageDetailViewController
        vc.dependency = dependency
        return vc
    }
    
    static func imageCommentsViewController(dependency: ImageCommentsViewController.Dependency) -> ImageCommentsViewController {
        let vc = UIStoryboard(name: "Image", bundle: nil).instantiateViewController(withIdentifier: "ImageCommentsViewController") as! ImageCommentsViewController
        vc.dependency = dependency
        return vc
    }
}
