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
    var refreshControl: UIRefreshControl!
    weak var collectionView: UICollectionView!
    weak var navigationItem: UINavigationItem!

    init(collectionView: UICollectionView, navigationItem: UINavigationItem) {
        self.collectionView = collectionView
        self.navigationItem = navigationItem
        self.setup()
    }
    
    private func setup() {
        prepareRefreshControl()
        prepareCategoryButton()
        prepareNavigationItem()
    }
    
    fileprivate func prepareRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl.tintColor = .primaryLight
        collectionView.addSubview(refreshControl!)
    }
    
    fileprivate func prepareCategoryButton() {
        categoryButton = IconButton(image: UIImage(named: "baseline_account_circle_black_24pt"), tintColor: .primaryText)
        categoryButton.pulseColor = .white
    }
    
    fileprivate func prepareNavigationItem() {
        navigationItem.titleLabel.text = "热门"
        navigationItem.titleLabel.textColor = .primaryText
//        navigationItem.titleLabel.textAlignment = .left
        navigationItem.rightViews = [categoryButton]
    }
    
    typealias Section = AnimatableSectionModel<String, MediumObject>
    typealias DataSource = RxCollectionViewSectionedAnimatedDataSource<Section>
    
    var items: (Driver<LoadFooterViewState>) -> (Observable<[Section]>) -> Disposable {
        return { [collectionView] loadState in
            let dataSource = DataSource(
                configureCell: { dataSource, collectionView, indexPath, item in
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RankMediumCell", for: indexPath) as! RankMediumCell
                    let viewModel = RankMediumCell.ViewModel(item: item)
                    cell.configure(with: viewModel)
                    return cell
            },
                configureSupplementaryView: { dataSource, collectionView, title, indexPath in
                    return UICollectionReusableView()
            }
            )
            return collectionView!.rx.items(dataSource: dataSource)
        }
    }
}

func createLoadFooterSupplementaryView<D>(loadState: Driver<LoadFooterViewState>) -> (D, UICollectionView, String, IndexPath) -> UICollectionReusableView {
    return { dataSource, collectionView, title, indexPath in
        let footer = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "CollectionLoadFooterView", for: indexPath) as! CollectionLoadFooterView
        loadState.drive(onNext: footer.contentView.on).disposed(by: footer.disposeBag)
        return footer
    }
}
