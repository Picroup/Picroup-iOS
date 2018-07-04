//
//  HomePresenter.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/9.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import Material
import RxSwift
import RxCocoa
import RxDataSources

fileprivate let fabMenuSize = CGSize(width: 56, height: 56)
fileprivate let bottomInset: CGFloat = 74
fileprivate let rightInset: CGFloat = 24

final class HomeViewPresenter: NSObject {
    
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    var fabButton: FABButton!
    var addUserButton: IconButton!
    var refreshControl: UIRefreshControl!
    weak var navigationItem: UINavigationItem!
    @IBOutlet weak var emptyView: UIView!

    func setup(navigationItem: UINavigationItem) {
        self.navigationItem = navigationItem
        prepareFABButton()
        prepareNavigationItem()
        prepareRefreshControl()
    }
    
    fileprivate func prepareFABButton() {
        fabButton = FABButton(image: Icon.cm.add, tintColor: .white)
        fabButton.pulseColor = .white
        fabButton.backgroundColor = .secondary
        
        view.layout(fabButton)
            .bottom(bottomInset)
            .right(rightInset)
            .size(fabMenuSize)
    }
    
    fileprivate func prepareNavigationItem() {
        navigationItem.titleLabel.text = "关注"
        navigationItem.titleLabel.textColor = .primaryText
        addUserButton = IconButton(image: UIImage(named: "ic_person_add"), tintColor: .primaryText)
        addUserButton.pulseColor = .white
        navigationItem.rightViews = [addUserButton]
    }
    
    fileprivate func prepareRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl.tintColor = .primaryLight
        collectionView.addSubview(refreshControl!)
    }
    
    typealias Section = AnimatableSectionModel<String, MediumObject>
    typealias DataSource = RxCollectionViewSectionedAnimatedDataSource<Section>
    
    var dataSource: DataSource?

    var items: (PublishRelay<HomeStateObject.Event>, Driver<LoadFooterViewState>) -> (Observable<[Section]>) -> Disposable {
        return { [weak self, collectionView] _events, loadState in
            let dataSource = DataSource(
                configureCell: { dataSource, collectionView, indexPath, item in
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeImageCell", for: indexPath) as! HomeImageCell
                    cell.configure(
                        with: item,
                        onCommentsTap: { _events.accept(.onTriggerShowComments(item._id)) },
                        onImageViewTap: { _events.accept(.onTriggerShowImage(item._id)) },
                        onUserTap: {
                            guard let userId = item.user?._id else { return }
                            _events.accept(.onTriggerShowUser(userId))
                    })
                    return cell
            },
                configureSupplementaryView: createLoadFooterSupplementaryView(loadState: loadState)
            )
            self?.dataSource = dataSource
            return collectionView!.rx.items(dataSource: dataSource)
        }
    }
    
    var isMyInterestedMediaEmpty: Binder<Bool> {
        return Binder(self) { presenter, isEmpty in
            presenter.collectionView.backgroundView = isEmpty ? presenter.emptyView : nil
        }
    }
    
    var isFabButtonHidden: Binder<Bool> {
        return Binder(self) { presenter, isHidden in
            UIView.animate(withDuration: 0.3) {
                presenter.fabButton.alpha = isHidden ? 0 : 1
            }
        }
    }
}

extension HomeViewPresenter: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let dataSource = dataSource else { return .zero }
        let medium = dataSource[indexPath]
        let width = collectionView.bounds.width - 16
        let imageHeight = width / CGFloat(medium.detail?.aspectRatio.value ?? 1)
        let height = imageHeight + 8 + 56
        return CGSize(width: width, height: height)
    }
}

