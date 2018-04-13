//
//  ErrorMessage.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/11.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation

public struct ErrorMessage: LocalizedError {
    public let message: String
    
    public init(_ message: String) {
        self.message = message
    }
}

extension ErrorMessage: CustomStringConvertible {
    public var description: String {
        return message
    }
    
    public var localizedDescription: String {
        return message
    }
}
