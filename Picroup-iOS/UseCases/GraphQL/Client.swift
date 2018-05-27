//
//  Client.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/11.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Apollo

extension ApolloClient {
    
    static let shared: ApolloClient = {
        let client = ApolloClient(url: URL(string: "\(Config.baseURL)/graphql")!)
        client.cacheKeyForObject = { $0["id"] }
        return client
    }()
}
