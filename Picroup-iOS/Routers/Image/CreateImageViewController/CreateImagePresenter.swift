//
//  CreateImagePresenter.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/22.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import Material

class CreateImagePresenter: NSObject {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var cancelButton: RaisedButton!
    @IBOutlet weak var saveButton: RaisedButton!
    @IBOutlet weak var progressView: UIProgressView!
    
    var items: (PublishRelay<CreateImageState.Event>) -> (Observable<[(category: MediumCategory, selected: Bool)]>) -> Disposable {
        return { eventsTrigger in { source in
            self.collectionView.rx.items(cellIdentifier: "CategoryCell", cellType: CategoryCell.self)(source) ({ index, viewModel, cell in
                cell.bind(name: viewModel.category.name, selected: viewModel.selected) {
                    eventsTrigger.accept(.onSelectedCategoryIndex(index))
                }
            })
            }}
    }
}

class CategoryCell: RxCollectionViewCell {
    @IBOutlet weak var button: RaisedButton!
    
    func bind(name: String, selected: Bool, onTap: @escaping () -> Void) {
        button.setTitle(name, for: .normal)
        setSelected(selected)
        bindButtonTap(to: onTap)
    }
    
    private func setSelected(_ selected: Bool) {
        if selected {
            button.titleColor = .primaryText
            button.backgroundColor = .primary
        } else {
            button.titleColor = .primary
            button.backgroundColor = .primaryText
        }
    }
    
    private func bindButtonTap(to onTap: @escaping () -> Void) {
        button.rx.tap
            .subscribe(onNext: onTap)
            .disposed(by: disposeBag)
    }
}
