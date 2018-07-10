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

final class RankViewPresenter: NSObject {
    
    var userButton: IconButton!
    var refreshControl: UIRefreshControl!
//    weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tagsCollectionView: UICollectionView! {
        didSet {
//            (tagsCollectionView.collectionViewLayout as! UICollectionViewFlowLayout)
//                .estimatedItemSize = CGSize(width: 50, height: 24)
        }
    }
    weak var navigationItem: UINavigationItem!
    @IBOutlet weak var hideTagsLayoutConstraint: NSLayoutConstraint!

    func setup(navigationItem: UINavigationItem) {
        self.navigationItem = navigationItem
        prepareRefreshControl()
        prepareUserButton()
        prepareNavigationItem()
    }
    
    fileprivate func prepareRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl.tintColor = .lightGray
        collectionView.addSubview(refreshControl!)
    }
    
    fileprivate func prepareUserButton() {
        userButton = IconButton(image: UIImage(named: "baseline_account_circle_black_24pt"), tintColor: .primaryText)
        userButton.pulseColor = .white
        userButton.isHidden = true
    }
    
    fileprivate func prepareNavigationItem() {
        navigationItem.titleLabel.text = "发现"
        navigationItem.titleLabel.textColor = .primaryText
//        navigationItem.titleLabel.textAlignment = .left
        navigationItem.rightViews = [userButton]
    }
    
    typealias Section = AnimatableSectionModel<String, MediumObject>
    typealias DataSource = RxCollectionViewSectionedReloadDataSource<Section>
    
    var items: (Driver<LoadFooterViewState>) -> (Observable<[Section]>) -> Disposable {
        return { [collectionView] loadState in
            let dataSource = DataSource(
                configureCell: { dataSource, collectionView, indexPath, item in
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RankMediumCell", for: indexPath) as! RankMediumCell
                    cell.configure(with: item)
                    return cell
            },
                configureSupplementaryView: createLoadFooterSupplementaryView(loadState: loadState)
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

extension RankViewPresenter: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CollectionViewLayoutManager.size(in: collectionView.bounds)
    }
}
