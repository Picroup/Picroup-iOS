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
        navigationItem.titleLabel.text = "热门"
        navigationItem.titleLabel.textColor = .primaryText
//        navigationItem.titleLabel.textAlignment = .left
        navigationItem.rightViews = [categoryButton]
    }
    
    typealias Section = AnimatableSectionModel<String, MediumFragment>
    typealias DataSource = RxCollectionViewSectionedAnimatedDataSource<Section>
    
    var items: (Observable<[Section]>) -> Disposable {
        let dataSource = DataSource(
            configureCell: { dataSource, collectionView, indexPath, item in
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RankMediumCell", for: indexPath) as! RankMediumCell
                let viewModel = RankMediumCell.ViewModel(item: item)
                cell.configure(with: viewModel)
                return cell
        },
            configureSupplementaryView: { dataSource, collectionView, title, indexPath in
                return UICollectionReusableView()
        })
        return collectionView.rx.items(dataSource: dataSource)
    }
}

extension RankedMediaQuery.Data.RankedMedium.Item: IdentifiableType, Equatable {
    
    public var identity: String {
        return id
    }
    
    public static func ==(lhs: RankedMediaQuery.Data.RankedMedium.Item, rhs: RankedMediaQuery.Data.RankedMedium.Item) -> Bool {
        return true
    }
}
