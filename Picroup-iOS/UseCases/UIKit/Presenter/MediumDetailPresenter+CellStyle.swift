//
//  ImageDetailPresenter+CellStyle.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/7/23.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RxDataSources

extension MediumDetailPresenter {
    
    enum SectionStyle: String {
        case imageDetail
        case imageTags
        case recommendMedia
    }
    
    enum CellStyle {
        case imageDetail(MediumObject)
        case imageTag(String)
        case recommendMedium(MediumObject)
    }
}

extension MediumDetailPresenter.CellStyle {
    
    var recommendMediumId: String? {
        if case .recommendMedium(let medium) = self {
            return medium._id
        }
        return nil
    }
}

extension MediumDetailPresenter.SectionStyle: IdentifiableType, Equatable {
    typealias Identity = String
    
    var identity: String {
        return rawValue
    }
}

extension MediumDetailPresenter.CellStyle: IdentifiableType, Equatable {
    typealias Identity = String
    
    var identity: String {
        switch self {
        case .imageDetail:
            return "imageDetail"
        case .imageTag(let tag):
            return "imageTag.\(tag)"
        case .recommendMedium(let medium):
            return "recommendMedium.\(medium._id)"
        }
    }
    
    static func ==(lhs: MediumDetailPresenter.CellStyle, rhs: MediumDetailPresenter.CellStyle) -> Bool {
        switch (lhs, rhs) {
        case (.imageDetail, imageDetail):
            return true
        case (.imageTag(let lTag), .imageTag(let rTag)):
            return lTag == rTag
        case (.recommendMedium(let lMedium), .recommendMedium(let rMedium)):
            return lMedium._id == rMedium._id
        default:
            return false
        }
    }
    
}

