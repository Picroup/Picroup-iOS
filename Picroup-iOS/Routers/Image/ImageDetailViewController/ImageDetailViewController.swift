//
//  ImageDetailViewController.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/16.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import Material
import RxSwift
import RxCocoa
import RxFeedback
import Apollo

class ImageDetailViewController: UIViewController {
    
    typealias Dependency = RankedMediaQuery.Data.RankedMedium.Item
    var dependency: Dependency!
    
    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupRxFeedback()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    private func setupRxFeedback() {
        
        Driver.just([dependency])
            .drive(collectionView .rx.items(cellIdentifier: "ImageDetailCell", cellType: ImageDetailCell.self)) { index, item, cell in
                cell.imageView.setImage(with: item?.minioId)
                cell.contentView.layer.cornerRadius = 5
                cell.contentView.layer.masksToBounds = true
        }
        .disposed(by: disposeBag)
        
        collectionView.rx.setDelegate(self).disposed(by: disposeBag)
    }
    
}

extension ImageDetailViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        let imageHeight = width / CGFloat(dependency.detail?.aspectRatio ?? 1)
        let height = imageHeight + 8 + 56 + 48 + 48
        return CGSize(width: width, height: height)
    }
}

class ImageDetailCell: RxCollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
}
