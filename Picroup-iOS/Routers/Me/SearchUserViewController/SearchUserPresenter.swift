//
//  SearchUserPresenter.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/23.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import Material
import RxSwift
import RxCocoa
import RxDataSources
import RxFeedback

private func onFollowButtonTap(_events: PublishRelay<SearchUserStateObject.Event>, item: UserObject)
    -> () -> Void {
        return {
            guard let followed = item.followed.value else { return }
            let event: SearchUserStateObject.Event = !followed ? .onTriggerFollowUser(item._id) : .onTriggerUnfollowUser(item._id)
            _events.accept(event)
        }
}

final class SearchUserPresenter: NSObject {
    
    weak var navigationItem: UINavigationItem!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadFooterView: LoadFooterView!

    func setup(navigationItem: UINavigationItem) {
        self.navigationItem = navigationItem
        searchBar.becomeFirstResponder()
        searchBar.autocapitalizationType = .none
        prepareNavigationItem()
    }
    
    fileprivate func prepareNavigationItem() {
        navigationItem.titleLabel.text = "搜索用户"
        navigationItem.titleLabel.textColor = .primaryText
    }
    
    typealias Section = SectionModel<String, UserObject>
    typealias DataSource = RxTableViewSectionedReloadDataSource<Section>
    
    var items: (PublishRelay<SearchUserStateObject.Event>) -> (Observable<[Section]>) -> Disposable {
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
}
