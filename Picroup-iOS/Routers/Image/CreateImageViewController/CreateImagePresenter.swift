//
//  CreateImagePresenter.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/22.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import Material

class CreateImagePresenter: NSObject {
    
    @IBOutlet weak var collectionView: UICollectionView!
//    @IBOutlet weak var saveButton: RaisedButton!
    @IBOutlet weak var progressView: UIProgressView!
}

extension CreateImagePresenter: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CollectionViewLayoutManager.size(in: collectionView.bounds)
    }
}

