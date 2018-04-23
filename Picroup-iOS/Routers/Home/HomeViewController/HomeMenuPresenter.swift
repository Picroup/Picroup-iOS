//
//  HomePresenter.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/9.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import Material
import RxCocoa

class HomeMenuPresenter {
    
    fileprivate let fabMenuSize = CGSize(width: 56, height: 56)
    fileprivate let bottomInset: CGFloat = 24
    fileprivate let rightInset: CGFloat = 24
    
    var fabButton: FABButton!
    var cameraFABMenuItem: FABMenuItem!
    var photoFABMenuItem: FABMenuItem!
    let view: UIView
    let fabMenu: FABMenu
    var addUserButton: IconButton!
    weak var navigationItem: UINavigationItem!


    init(view: UIView, fabMenu: FABMenu, navigationItem: UINavigationItem) {
        self.view = view
        self.fabMenu = fabMenu
        self.navigationItem = navigationItem
        self.setup()
    }
    
    private func setup() {
//        view.backgroundColor = .white
        fabMenu.delegate = nil

        prepareFABButton()
        preparePhotoFABMenuItem()
        prepareCameraFABMenuItem()
        prepareFABMenu()
        prepareCategoryButton()
        prepareNavigationItem()
    }
    
    fileprivate func prepareFABButton() {
        fabButton = FABButton(image: Icon.cm.add, tintColor: .white)
        fabButton.pulseColor = .white
        fabButton.backgroundColor = .secondary
    }
    
    fileprivate func preparePhotoFABMenuItem() {
        cameraFABMenuItem = FABMenuItem()
//        notesFABMenuItem.title = "Audio Library"
        cameraFABMenuItem.fabButton.image = UIImage(named: "ic_photo_camera")
        cameraFABMenuItem.fabButton.tintColor = .white
        cameraFABMenuItem.fabButton.pulseColor = .white
        cameraFABMenuItem.fabButton.backgroundColor = .primaryLight
    }
    
    fileprivate func prepareCameraFABMenuItem() {
        photoFABMenuItem = FABMenuItem()
//        remindersFABMenuItem.title = "Reminders"
        photoFABMenuItem.fabButton.image = UIImage(named: "ic_photo")
        photoFABMenuItem.fabButton.tintColor = .white
        photoFABMenuItem.fabButton.pulseColor = .white
        photoFABMenuItem.fabButton.backgroundColor = Color.blue.base
    }
    
    fileprivate func prepareFABMenu() {
        fabMenu.fabButton = fabButton
        fabMenu.fabMenuItems = [cameraFABMenuItem, photoFABMenuItem]
        
        view.layout(fabMenu)
            .bottom(bottomInset)
            .right(rightInset)
            .size(fabMenuSize)
    }
    
    fileprivate func prepareCategoryButton() {
        navigationItem.titleLabel.text = "关注"
        navigationItem.titleLabel.textColor = .primaryText
        addUserButton = IconButton(image: UIImage(named: "ic_person_add"), tintColor: .primaryText)
        addUserButton.pulseColor = .white
    }
    
    fileprivate func prepareNavigationItem() {
        navigationItem.rightViews = [addUserButton]
    }
    
    var isFABMenuOpened: Binder<Bool> {
        return Binder(self) { me, isOpen in
            let z: CGFloat = isOpen ? 45 : 0
            me.fabMenu.fabButton?.animate(.rotate(z))
        }
    }
}
