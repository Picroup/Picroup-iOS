//
//  ApolloClient+Rx.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/8.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RxSwift
import Apollo

extension ApolloClient: ReactiveCompatible {}

extension Reactive where Base: ApolloClient {
    
    public func fetch<Query: GraphQLQuery>(query: Query, cachePolicy: CachePolicy = .returnCacheDataElseFetch) -> Single<GraphQLResult<Query.Data>?> {
        
        return Single.create { [client = base] observer in
            let cancellable = client.fetch(query: query, cachePolicy: cachePolicy) { (result, error) in
                if let error = error {
                    observer(.error(error))
                    return
                }
                if let error = result?.errors?.first {
                    observer(.error(error))
                    return
                }
                
                observer(.success(result))
            }
            return Disposables.create(with: cancellable.cancel)
        }
    }
    
    public func perform<Mutation: GraphQLMutation>(mutation: Mutation)  -> Single<GraphQLResult<Mutation.Data>?> {
        
        return Single.create { [client = base] observer in
            let cancellable = client.perform(mutation: mutation) { (result, error) in
                if let error = error {
                    observer(.error(error))
                    return
                }
                if let error = result?.errors?.first {
                    observer(.error(error))
                    return
                }
                
                observer(.success(result))
            }
            return Disposables.create(with: cancellable.cancel)
        }
    }
}

