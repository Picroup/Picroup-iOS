//
//  FollowersPresenter.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/22.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import Material
import RxSwift
import RxCocoa
import RxDataSources
import RxFeedback

private func onFollowButtonTap(_events: PublishRelay<UserFollowersStateObject.Event>, item: UserObject)
    -> () -> Void {
        return {
            guard let followed = item.followed.value else { return }
            let event: UserFollowersStateObject.Event = !followed ? .onTriggerFollowUser(item._id) : .onTriggerUnfollowUser(item._id)
            _events.accept(event)
        }
}

final class FollowersPresenter: NSObject {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadFooterView: LoadFooterView!
    @IBOutlet weak var emptyView: UIView!
    
    func setup(navigationItem: UINavigationItem) {
        
        navigationItem.titleLabel.text = "粉丝"
        navigationItem.titleLabel.textColor = .primaryText
        
        navigationItem.detailLabel.text = "0 人"
        navigationItem.detailLabel.textColor = .primaryText
    }

    typealias Section = SectionModel<String, UserObject>
    typealias DataSource = RxTableViewSectionedReloadDataSource<Section>
    
    var items: (PublishRelay<UserFollowersStateObject.Event>) -> (Observable<[Section]>) -> Disposable {
        return { [tableView] _events in
            let dataSource = DataSource(
                configureCell: { dataSource, tableView, indexPath, item in
                    let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserCell
                    cell.configure(
                        with: item,
                        onFollowButtonTap: onFollowButtonTap(_events: _events, item: item)
                    )
                    return cell
            })
            return tableView!.rx.items(dataSource: dataSource)
        }
    }
    
    var isFollowersEmpty: Binder<Bool> {
        return Binder(self) { presenter, isEmpty in
            presenter.tableView.backgroundView = isEmpty ? presenter.emptyView : nil
        }
    }
}
