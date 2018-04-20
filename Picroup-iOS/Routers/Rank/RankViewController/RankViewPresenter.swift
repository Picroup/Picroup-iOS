//
//  RankViewPresenter.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/16.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import Material
import RxSwift
import RxCocoa
import RxDataSources

class RankViewPresenter {
    
    var categoryButton: IconButton!
    weak var collectionView: UICollectionView!
    weak var navigationItem: UINavigationItem!

    init(collectionView: UICollectionView, navigationItem: UINavigationItem) {
        self.collectionView = collectionView
        self.navigationItem = navigationItem
        self.setup()
    }
    
    private func setup() {
        prepareCategoryButton()
        prepareNavigationItem()
    }
    
    fileprivate func prepareCategoryButton() {
        categoryButton = IconButton(image: Icon.cm.arrowDownward, tintColor: .primaryText)
        categoryButton.pulseColor = .white
    }
    
    fileprivate func prepareNavigationItem() {
        navigationItem.titleLabel.text = "全部"
        navigationItem.titleLabel.textColor = .primaryText
//        navigationItem.titleLabel.textAlignment = .left
        navigationItem.rightViews = [categoryButton]
    }
    
    typealias Section = AnimatableSectionModel<String, RankedMediaQuery.Data.RankedMedium.Item>
    typealias DataSource = RxCollectionViewSectionedAnimatedDataSource<Section>
    
    var items: (Observable<[Section]>) -> Disposable {
        let dataSource = DataSource(
            configureCell: { dataSource, collectionView, indexPath, item in
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RankMediumCell", for: indexPath) as! RankMediumCell
                cell.imageView.setImage(with: item.minioId)
                cell.imageView.motionIdentifier = item.id
                cell.transition(.fadeOut, .scale(0.75))
                cell.progressView.progress = Float(item.remainTime / 56.days)
                cell.progressView.motionIdentifier = "lifeBar_\(item.id)"
                cell.starPlaceholderView.motionIdentifier = "starButton_\(item.id)"
                return cell
        },
            configureSupplementaryView: { dataSource, collectionView, title, indexPath in
                return UICollectionReusableView()
        })
        return collectionView.rx.items(dataSource: dataSource)
    }
}
