//
//  CommentObject.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/16.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift
import Apollo

final class CommentObject: PrimaryObject {
    
    @objc dynamic var userId: String?
    @objc dynamic var content: String?
    let createdAt = RealmOptional<Double>()
    @objc dynamic var user: UserObject?
}

final class CursorCommentsObject: PrimaryObject {
    
    let cursor = RealmOptional<Double>()
    let items = List<CommentObject>()
}

extension CursorCommentsObject: IsCursorItemsObject {
    typealias CursorItemsFragment = CursorCommentsFragment
}

extension CursorCommentsFragment: IsCursorFragment {}

