//
//  RankViewController.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/10.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import RxFeedback
import Material
import Apollo

class RankViewController: UIViewController {
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    private let disposeBag = DisposeBag()
    typealias Feedback = (Driver<RankState>) -> Signal<RankState.Event>
    
    override func didMove(toParentViewController parent: UIViewController?) {
        super.didMove(toParentViewController: parent)
        print("didMove toParentViewController")
        setupRxFeedback()
    }
    
    private func setupRxFeedback() {
        
        typealias Section = AnimatableSectionModel<String, RankedMediaQuery.Data.RankedMedium.Item>
        typealias DataSource = RxCollectionViewSectionedAnimatedDataSource<Section>
        
        
        let dataSource = DataSource(
            configureCell: { dataSource, collectionView, indexPath, item in
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RankMediumCell", for: indexPath) as! RankMediumCell
                cell.imageView.setImage(with: item.minioId)
                return cell
        },
            configureSupplementaryView: { dataSource, collectionView, title, indexPath in
                return UICollectionReusableView()
        })
        
        let uiFeedback: Feedback = bind(self) { (me, state)  in
            let subscriptions = [
                state.map { [Section(model: "", items: $0.items)] }.drive(me.collectionView.rx.items(dataSource: dataSource))
            ]
            let events: [Signal<RankState.Event>] = [
                state.flatMapLatest {
                    $0.shouldQueryMore ? me.collectionView.rx.isNearBottom.asSignal() : .empty()
                    }.map { RankState.Event.onTriggerGetMore }
            ]
            return Bindings(subscriptions: subscriptions, events: events)
        }
        
        let queryMedia: Feedback = react(query: { $0.rankedMediaQuery }) { query in
            ApolloClient.shared.rx.fetch(query: query).map { $0?.data?.rankedMedia }.unwrap().map(RankState.Event.onGetSuccess)
                .asSignal(onErrorRecover: { error in .just(.onGetError(error) )})
        }
        
        Driver<Any>.system(
            initialState: RankState.empty,
            reduce: logger(identifier: "RankState")(RankState.reduce),
            feedback: uiFeedback, queryMedia
        )
        .drive()
        .disposed(by: disposeBag)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let selectCategoryButton = self.toolbarController!.toolbar.leftViews.first as! IconButton
            
            selectCategoryButton.rx.tap
                .subscribe(onNext: { [weak self] in
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SelectCategoryViewController")
                    self?.present(vc, animated: true)
                })
                .disposed(by: self.disposeBag)
        }
    }
}

class RankMediumCell: RxCollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
}

extension RankedMediaQuery.Data.RankedMedium.Item: IdentifiableType, Equatable {
    
    public var identity: String {
        return id
    }
    
    public static func ==(lhs: RankedMediaQuery.Data.RankedMedium.Item, rhs: RankedMediaQuery.Data.RankedMedium.Item) -> Bool {
        return true
    }
}
