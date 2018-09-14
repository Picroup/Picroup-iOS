//
//  MediumPresentable.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/9/14.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import class UIKit.UIColor
import RxSwift
import RxCocoa

protocol MediumPresentable: BasePresentable {
    var mediumKind: MediumKind? { get }
    var imageURL: URL? { get }
    var lifeProgress: Float { get }
    var remainTimeDisplay: String { get }
    var commentsCountDisplay: String { get }
    var placeholderColor: UIColor { get }
    var isStared: Bool? { get }
    
    var userDisplay: UserPresentable? { get }

    var cellMotionIdentifier: String? { get }
    var imageViewMotionIdentifier: String? { get }
    var lifeBarMotionIdentifier: String? { get }
    var remainTimeLabelMotionIdentifier: String? { get }
    var starButtonMotionIdentifier: String? { get }
    
    func asDriver() -> Driver<MediumPresentable>
}

extension MediumObject: MediumPresentable {
    
    var mediumKind: MediumKind? {
        return kind.flatMap(MediumKind.init(rawValue: ))
    }
    
    var imageURL: URL? {
        return url?.toURL()
    }
    
    var lifeProgress: Float {
        return Float(remainTime / 12.0.weeks)
    }
    
    var remainTimeDisplay: String {
        return Moment.string(from: endedAt.value)
    }
    
    var commentsCountDisplay: String {
        return "  \(commentsCount.value ?? 0)"
    }
    
    var userDisplay: UserPresentable? {
        return user
    }
    
    var isStared: Bool? {
        return stared.value
    }
    
    var cellMotionIdentifier: String? {
        return "cell.\(_id)"
    }
    
    var imageViewMotionIdentifier: String? {
        return "imageView.\(_id)"
    }
    
    var lifeBarMotionIdentifier: String? {
        return "lifeBar.\(_id)"
    }
    
    var remainTimeLabelMotionIdentifier: String? {
        return "remainTimeLabel.\(_id)"
    }
    
    var starButtonMotionIdentifier: String? {
        return "starButton.\(_id)"
    }
    
    func asDriver() -> Driver<MediumPresentable> {
        return rx.observe().map { $0 }
            .asDriverOnErrorRecoverEmpty()
    }
    
    private var remainTime: Double {
        return endedAt.value?.sinceNow ?? 0
    }
    
}
