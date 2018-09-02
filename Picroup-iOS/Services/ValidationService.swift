//
//  ValidationService.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/9/2.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RxSwift

extension ValidationService {
    
    enum Error: Swift.Error {
        case usernameIsEmpty
        case usernameNotValid
        case usernameInUse
        
        case passwordIsEmpty
        case passwordNotValid
    }
}

extension ValidationService.Error: LocalizedError {
    
    var errorDescription: String? {
        switch self {
        case .usernameIsEmpty: return "用户名不能为空"
        case .usernameNotValid: return "字母加数字，至少需要 4 个字"
        case .usernameInUse: return "用户名已被注册"
            
        case .passwordIsEmpty: return "密码不能为空"
        case .passwordNotValid: return "至少需要 6 个字"
        }
    }
}

struct ValidationService {
    
    static func queryIsRegisterUsernameAvailable(queryUsernameAvailable: @escaping (UsernameAvailableQuery) -> Single<UsernameAvailableQuery.Data.SearchUser?>) -> (String) -> Single<Void> {
        return { username in
            
            guard !username.isEmpty else {
                return Single.error(Error.usernameIsEmpty)
            }
            
            guard username.matchExpression(RegularPattern.username) else {
                return Single.error(Error.usernameNotValid)
            }
            
            let query = UsernameAvailableQuery(username: username)
            return queryUsernameAvailable(query)
                .map { data in
                    guard data == nil else { throw Error.usernameInUse }
                    return ()
            }
        }
    }
    
    static func queryValidPassword() -> (String) -> Single<Void> {
        return { password in
            
            guard !password.isEmpty else {
                return Single.error(Error.passwordIsEmpty)
            }
            
            guard password.matchExpression(RegularPattern.password) else {
                return Single.error(Error.passwordNotValid)
            }
            
            return .just(())
        }
    }
}
