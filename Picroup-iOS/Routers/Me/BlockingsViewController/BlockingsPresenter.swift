//
//  BlockingsPresenter.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/8/3.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import Material
import RxSwift
import RxCocoa
import RxDataSources
import RxFeedback

private func onBlockButtonTap(_events: PublishRelay<UserBlockingsStateObject.Event>, item: UserObject)
    -> () -> Void {
        return {
            guard let blocked = item.blocked.value else { return }
            let event: UserBlockingsStateObject.Event = !blocked ? .onTriggerBlockUser(item._id) : .onTriggerUnblockUser(item._id)
            _events.accept(event)
        }
}

final class BlockingsPresenter: NSObject {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadFooterView: LoadFooterView!
    @IBOutlet weak var emptyView: UIView!
    
    func setup(navigationItem: UINavigationItem) {
        
        navigationItem.titleLabel.text = "黑名单"
        navigationItem.titleLabel.textColor = .primaryText
    }
    
    typealias Section = SectionModel<String, UserObject>
    typealias DataSource = RxTableViewSectionedReloadDataSource<Section>
    
    
    
    var items: (PublishRelay<UserBlockingsStateObject.Event>) -> (Observable<[Section]>) -> Disposable {
        return { [tableView] _events in
            let dataSource = DataSource(
                configureCell: { dataSource, tableView, indexPath, item in
                    let cell = tableView.dequeueReusableCell(withIdentifier: "BlockUserCell", for: indexPath) as! BlockUserCell
                    cell.configure(
                        with: item,
                        onBlockButtonTap: onBlockButtonTap(_events: _events, item: item)
                    )
                    return cell
            })
            return tableView!.rx.items(dataSource: dataSource)
        }
    }
    
    var isBlockingsEmpty: Binder<Bool> {
        return Binder(self) { presenter, isEmpty in
            presenter.tableView.backgroundView = isEmpty ? presenter.emptyView : nil
        }
    }
}
