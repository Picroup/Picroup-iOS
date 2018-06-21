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

extension RouterService {
    
    enum Image {}
}
extension RouterService.Image {
    
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
