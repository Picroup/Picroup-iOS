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


    init(view: UIView, fabMenu: FABMenu) {
        self.view = view
        self.fabMenu = fabMenu
        self.setup()
    }
    
    private func setup() {
        view.backgroundColor = .white
        
        prepareFABButton()
        preparePhotoFABMenuItem()
        prepareCameraFABMenuItem()
        prepareFABMenu()

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
//        notesFABMenuItem.fabButton.addTarget(self, action: #selector(handleNotesFABMenuItem(button:)), for: .touchUpInside)
    }
    
    fileprivate func prepareCameraFABMenuItem() {
        photoFABMenuItem = FABMenuItem()
//        remindersFABMenuItem.title = "Reminders"
        photoFABMenuItem.fabButton.image = UIImage(named: "ic_photo")
        photoFABMenuItem.fabButton.tintColor = .white
        photoFABMenuItem.fabButton.pulseColor = .white
        photoFABMenuItem.fabButton.backgroundColor = Color.blue.base
//        remindersFABMenuItem.fabButton.addTarget(self, action: #selector(handleRemindersFABMenuItem(button:)), for: .touchUpInside)
    }
    
    fileprivate func prepareFABMenu() {
        fabMenu.fabButton = fabButton
        fabMenu.fabMenuItems = [cameraFABMenuItem, photoFABMenuItem]
//        fabMenuBacking = .none
        
        view.layout(fabMenu)
            .bottom(bottomInset)
            .right(rightInset)
            .size(fabMenuSize)
    }
}
