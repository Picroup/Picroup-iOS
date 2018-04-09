//
//  LoginService.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/9.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Apollo

extension RouterService {
    
    enum Login {}
}

extension RouterService.Login {
    
    static func loginViewController(client: ApolloClient, observer: @escaping (UserQuery.Data.User) -> Void) -> LoginViewController {
        return LoginViewController(dependency: (client, observer))
    }
    
}

