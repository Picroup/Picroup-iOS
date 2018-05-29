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
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var followersCountLabel: UILabel!
    @IBOutlet weak var loadFooterView: LoadFooterView!

    typealias Section = SectionModel<String, UserObject>
    typealias DataSource = RxTableViewSectionedReloadDataSource<Section>
    
    var items: (PublishRelay<UserFollowersStateObject.Event>) -> (Observable<[Section]>) -> Disposable {
        return { [tableView] _events in
            let dataSource = DataSource(
                configureCell: { dataSource, tableView, indexPath, item in
                    let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserCell
                    let viewModel = UserViewModel(user: item)
                    cell.configure(
                        with: viewModel,
                        onFollowButtonTap: onFollowButtonTap(_events: _events, item: item)
                    )
                    return cell
            })
            return tableView!.rx.items(dataSource: dataSource)
        }
    }
}
