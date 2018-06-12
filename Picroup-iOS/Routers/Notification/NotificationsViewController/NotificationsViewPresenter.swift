//
//  NotificationsViewPresenter.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/25.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

class NotificationsViewPresenter: NSObject {
    @IBOutlet weak var tableView: UITableView!
    weak var navigationItem: UINavigationItem!
    @IBOutlet weak var loadFooterView: LoadFooterView!
    @IBOutlet weak var emptyView: UIView!

    func setup(navigationItem: UINavigationItem) {
        self.navigationItem = navigationItem
        prepareNavigationItem()
    }
    
    fileprivate func prepareNavigationItem() {
        navigationItem.titleLabel.text = "通知"
        navigationItem.titleLabel.textColor = .primaryText
    }
    
    typealias Section = AnimatableSectionModel<String, NotificationObject>
    typealias DataSource = RxTableViewSectionedAnimatedDataSource<Section>
    
    var items: (Observable<[Section]>) -> Disposable {
        let dataSource = DataSource(
            configureCell: { dataSource, tableView, indexPath, item in
                let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath) as! NotificationCell
                cell.configure(with: item)
                return cell
        })
        return tableView.rx.items(dataSource: dataSource)
    }
    
    var isNotificationsEmpty: Binder<Bool> {
        return Binder(self) { presenter, isEmpty in
            presenter.tableView.backgroundView = isEmpty ? presenter.emptyView : nil
        }
    }
}
