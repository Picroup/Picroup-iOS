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
        case usernameNotValid
        case usernameInUse
        
        case passwordNotValid
        
        case phoneNumberNotValid
        case phoneNumberInUse
        
        case codeNotValid

    }
}

extension ValidationService.Error: LocalizedError {
    
    var errorDescription: String? {
        switch self {
        case .usernameNotValid: return "字母加数字，至少需要 4 个字"
        case .usernameInUse: return "用户名已被注册"
            
        case .passwordNotValid: return "至少需要 6 个字"
            
        case .phoneNumberNotValid: return "请输入 11 位手机号"
        case .phoneNumberInUse: return "手机号已被注册"
            
        case .codeNotValid: return "请输入 6 位验证码"
        }
    }
}

struct ValidationService {
    
    static func queryIsRegisterUsernameAvailable(queryUsernameAvailable: @escaping (UsernameAvailableQuery) -> Single<UsernameAvailableQuery.Data.SearchUser?>) -> (String) -> Single<Void> {
        return { username in
            
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
            
            guard password.matchExpression(RegularPattern.password) else {
                return Single.error(Error.passwordNotValid)
            }
            
            return .just(())
        }
    }
    
    static func queryIsRegisterPhoneNumberAvailable(queryPhoneNumberAvailable: @escaping (PhoneNumberAvailableQuery) -> Single<PhoneNumberAvailableQuery.Data.SearchUserByPhoneNumber?>) -> (String) -> Single<Void> {
        return { phoneNumber in
            
            guard phoneNumber.matchExpression(RegularPattern.chinesePhone) else {
                return Single.error(Error.phoneNumberNotValid)
            }
            
            let query = PhoneNumberAvailableQuery(phoneNumber: phoneNumber)
            return queryPhoneNumberAvailable(query)
                .map { data in
                    guard data == nil else { throw Error.phoneNumberInUse }
                    return ()
            }
        }
    }
    
    static func queryValidCode() -> (Double) -> Single<Void> {
        return { code in
            
            guard Int(code).description.matchExpression(RegularPattern.code6) else {
                return Single.error(Error.codeNotValid)
            }
            
            return .just(())
        }
    }
}
