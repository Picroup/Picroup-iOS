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
    @IBOutlet weak var tagsCollectionView: UICollectionView!
    weak var navigationItem: UINavigationItem!
    @IBOutlet weak var hideTagsLayoutConstraint: NSLayoutConstraint!

    func setup(navigationItem: UINavigationItem) {
        self.navigationItem = navigationItem
        prepareCollectionView()
        prepareTagsCollectionView()
        prepareRefreshControl()
        prepareUserButton()
        prepareNavigationItem()
    }
    
    fileprivate func prepareCollectionView() {
        
        collectionView.register(UINib(nibName: "RankMediumCell", bundle: nil), forCellWithReuseIdentifier: "RankMediumCell")
        collectionView.register(UINib(nibName: "RankVideoCell", bundle: nil), forCellWithReuseIdentifier: "RankVideoCell")
    }
    
    fileprivate func prepareTagsCollectionView() {
        
        tagsCollectionView.register(UINib(nibName: "TagCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TagCollectionViewCell")
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
    var dataSource: DataSource?

    var items: (Driver<LoadFooterViewState>) -> (Observable<[Section]>) -> Disposable {
        return { [collectionView] loadState in
            let dataSource = DataSource(
                configureCell: configureMediumCell(),
                configureSupplementaryView: createLoadFooterSupplementaryView(loadState: loadState)
            )
            self.dataSource = dataSource
            return collectionView!.rx.items(dataSource: dataSource)
        }
    }
    
}

func configureMediumCell<D>() -> (D, UICollectionView, IndexPath, MediumObject) -> UICollectionViewCell {
    return { dataSource, collectionView, indexPath, item in
        let defaultCell: () -> UICollectionViewCell = {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RankMediumCell", for: indexPath) as! RankMediumCell
            cell.configure(with: item)
            return cell
        }
        guard !item.isInvalidated else { return defaultCell() }
        switch item.kind {
        case MediumKind.video.rawValue?:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RankVideoCell", for: indexPath) as! RankVideoCell
            cell.configure(with: item)
            return cell
        default:
            return defaultCell()
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


func playVideoIfNeeded(cell: UICollectionViewCell, medium: MediumObject?) {
    if let vidoeCell = cell as? HasPlayerView, medium?.isInvalidated == false {
        vidoeCell.playerView.play(with: medium?.detail?.videoMinioId)
    }
}

func resetPlayerIfNeeded(cell: UICollectionViewCell) {
    if let vidoeCell = cell as? HasPlayerView {
        vidoeCell.playerView.reset()
    }
}

extension RankViewPresenter: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CollectionViewLayoutManager.size(in: collectionView.bounds, with: dataSource?[indexPath])
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        playVideoIfNeeded(cell: cell, medium: dataSource?[indexPath])
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        resetPlayerIfNeeded(cell: cell)
    }
}
