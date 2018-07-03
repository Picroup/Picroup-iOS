//
//  ReputationsViewPresenter.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/24.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class ReputationsViewPresenter: NSObject {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadFooterView: LoadFooterView!
    @IBOutlet weak var emptyView: UIView!
    
    func setup(navigationItem: UINavigationItem) {
        
        navigationItem.titleLabel.text = "灵性"
        navigationItem.titleLabel.textColor = .primaryText
        
        navigationItem.detailLabel.text = " "
        navigationItem.detailLabel.textColor = .primaryText
    }

    typealias Section = AnimatableSectionModel<String, ReputationObject>
    typealias DataSource = RxTableViewSectionedAnimatedDataSource<Section>
    
    var items: (Observable<[Section]>) -> Disposable {
        let dataSource = DataSource(
            configureCell: { dataSource, tableView, indexPath, item in
                let cell = tableView.dequeueReusableCell(withIdentifier: "ReputationCell", for: indexPath) as! ReputationCell
                cell.configure(with: item)
                return cell
        })
        return tableView.rx.items(dataSource: dataSource)
    }
    
    var isReputationsEmpty: Binder<Bool> {
        return Binder(self) { presenter, isEmpty in
            presenter.tableView.backgroundView = isEmpty ? presenter.emptyView : nil
        }
    }
}
