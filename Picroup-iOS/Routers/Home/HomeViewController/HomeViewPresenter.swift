//
//  HomeViewPresenter.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/20.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class HomeViewPresenter: NSObject {
    @IBOutlet weak var collectionView: UICollectionView!
    
    typealias Section = AnimatableSectionModel<String, HomeState.Item>
    typealias DataSource = RxCollectionViewSectionedAnimatedDataSource<Section>
    
    fileprivate lazy var dataSource = DataSource(
        configureCell: { dataSource, collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeImageCell", for: indexPath) as! HomeImageCell
            cell.imageView.setImage(with: item.minioId)
            cell.lifeViewWidthConstraint.constant = CGFloat(item.endedAt.sinceNow / 8.0.weeks) * cell.lifeBar.bounds.width
            cell.imageView.motionIdentifier = item.id
            cell.lifeBar.motionIdentifier = "lifeBar_\(item.id)"
            return cell
    },
        configureSupplementaryView: { dataSource, collectionView, title, indexPath in
            return UICollectionReusableView()
    })
    
    var items: (Observable<[Section]>) -> Disposable {
        return collectionView.rx.items(dataSource: dataSource)
    }
}

extension HomeViewPresenter: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width - 16
//        let item = dataSource.sectionModels[indexPath.section].items[indexPath.item]
        let imageHeight = width
        let height = imageHeight + 8 + 56 + 1 + 48
        return CGSize(width: width, height: height)
    }
}

extension UserInterestedMediaQuery.Data.User.InterestedMedium.Item: IdentifiableType, Equatable {
    public typealias Identity = String
    public var identity: String {
        return id
    }
    
    public static func ==(lhs: UserInterestedMediaQuery.Data.User.InterestedMedium.Item, rhs: UserInterestedMediaQuery.Data.User.InterestedMedium.Item) -> Bool {
        return true
    }
}
