//
//  ImageDetailPresenter.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/9.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import Material
import RxSwift
import RxCocoa
import RxDataSources

class ImageDetailPresenter: NSObject {
    
    @IBOutlet weak var deleteAlertView: UIView!
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet { prepareCollectionView() }
    }
    @IBOutlet weak var backgroundButton: UIButton!
    var mediumDetailPresenter: MediumDetailPresenter!

    fileprivate func prepareCollectionView() {
        self.mediumDetailPresenter = MediumDetailPresenter(collectionView: collectionView)
    }
}



