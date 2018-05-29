//
//  MePresenter.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/23.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import Material
import RxSwift
import RxCocoa
import RxDataSources

class MePresenter: NSObject {
    @IBOutlet weak var meBackgroundView: UIView!
    @IBOutlet weak var userAvatarImageView: UIImageView!
    @IBOutlet weak var displaynameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!

    @IBOutlet weak var reputationCountLabel: UILabel!
    @IBOutlet weak var gainedReputationCountButton: UIButton!
    @IBOutlet weak var followersCountLabel: UILabel!
    @IBOutlet weak var followingsCountLabel: UILabel!
    
    @IBOutlet weak var reputationButton: UIButton!
    @IBOutlet weak var followersButton: UIButton!
    @IBOutlet weak var followingsButton: UIButton!

    @IBOutlet weak var myMediaButton: UIButton!
    @IBOutlet weak var myStaredMediaButton: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var myMediaCollectionView: UICollectionView!
    @IBOutlet weak var myStardMediaCollectionView: UICollectionView!

    @IBOutlet weak var selectMyMediaLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var hideDetailLayoutConstraint: NSLayoutConstraint!
    private var isFirstTimeSetSelectedTab = true
    
    typealias Section = AnimatableSectionModel<String, MediumObject>
    typealias DataSource = RxCollectionViewSectionedAnimatedDataSource<Section>
    
    var selectedTabIndex: Binder<Int> {
        return Binder(self) { me, index in
            guard let tab = MeStateObject.Tab(rawValue: index) else { return }
            let offsetX = CGFloat(tab.rawValue) * me.scrollView.frame.width
            let offsetY = me.scrollView.contentOffset.y
            let animated = !me.isFirstTimeSetSelectedTab
            me.isFirstTimeSetSelectedTab = false
            me.scrollView.setContentOffset(CGPoint(x: offsetX, y: offsetY), animated: animated)
            me.selectMyMediaLayoutConstraint.isActive = tab == .myMedia
            UIView.animate(withDuration: animated ? 0.3 : 0, animations: me.meBackgroundView.layoutIfNeeded)
        }
    }
    
    private var dataSource: (Driver<LoadFooterViewState>) -> DataSource {
        return { loadState in
            return DataSource(
                configureCell: { dataSource, collectionView, indexPath, item in
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RankMediumCell", for: indexPath) as! RankMediumCell
                    let viewModel = RankMediumCell.ViewModel(item: item)
                    cell.configure(with: viewModel)
                    return cell
            },
                configureSupplementaryView: { dataSource, collectionView, title, indexPath in
                    let footer = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "CollectionLoadFooterView", for: indexPath) as! CollectionLoadFooterView
                    loadState.drive(onNext: footer.contentView.on).disposed(by: footer.disposeBag)
                    return footer
            })
        }
    }
    
    var myMediaItems: (Driver<LoadFooterViewState>) -> (Observable<[Section]>) -> Disposable {
        return { [myMediaCollectionView] loadState in
            return myMediaCollectionView!.rx.items(dataSource: self.dataSource(loadState))
        }
    }
    
    var myStaredMediaItems: (Driver<LoadFooterViewState>) -> (Observable<[Section]>) -> Disposable {
        return { [myStardMediaCollectionView] loadState in
            return myStardMediaCollectionView!.rx.items(dataSource: self.dataSource(loadState))
        }
    }
}
