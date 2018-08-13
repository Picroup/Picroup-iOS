//
//  URLHelper.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/7/18.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation

struct URLHelper {
    
    static func url(from minioId: String?) -> URL? {
        return minioId
            .map { "\(Config.baseURL)/files/\($0)" }
            .flatMap(URL.init(string: ))
    }    
}

