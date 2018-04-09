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

class HomePresenter {
    
    fileprivate let fabMenuSize = CGSize(width: 56, height: 56)
    fileprivate let bottomInset: CGFloat = 24
    fileprivate let rightInset: CGFloat = 24
    
    var fabButton: FABButton!
    var notesFABMenuItem: FABMenuItem!
    var remindersFABMenuItem: FABMenuItem!
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
        prepareNotesFABMenuItem()
        prepareRemindersFABMenuItem()
        prepareFABMenu()

    }
    fileprivate func prepareFABButton() {
        fabButton = FABButton(image: Icon.cm.add, tintColor: .white)
        fabButton.pulseColor = .white
        fabButton.backgroundColor = Color.red.base
    }
    
    fileprivate func prepareNotesFABMenuItem() {
        notesFABMenuItem = FABMenuItem()
        notesFABMenuItem.title = "Audio Library"
        notesFABMenuItem.fabButton.image = Icon.cm.pen
        notesFABMenuItem.fabButton.tintColor = .white
        notesFABMenuItem.fabButton.pulseColor = .white
        notesFABMenuItem.fabButton.backgroundColor = Color.green.base
//        notesFABMenuItem.fabButton.addTarget(self, action: #selector(handleNotesFABMenuItem(button:)), for: .touchUpInside)
    }
    
    fileprivate func prepareRemindersFABMenuItem() {
        remindersFABMenuItem = FABMenuItem()
        remindersFABMenuItem.title = "Reminders"
        remindersFABMenuItem.fabButton.image = Icon.cm.bell
        remindersFABMenuItem.fabButton.tintColor = .white
        remindersFABMenuItem.fabButton.pulseColor = .white
        remindersFABMenuItem.fabButton.backgroundColor = Color.blue.base
//        remindersFABMenuItem.fabButton.addTarget(self, action: #selector(handleRemindersFABMenuItem(button:)), for: .touchUpInside)
    }
    
    fileprivate func prepareFABMenu() {
        fabMenu.fabButton = fabButton
        fabMenu.fabMenuItems = [notesFABMenuItem, remindersFABMenuItem]
//        fabMenuBacking = .none
        
        view.layout(fabMenu)
            .bottom(bottomInset)
            .right(rightInset)
            .size(fabMenuSize)
    }
}
