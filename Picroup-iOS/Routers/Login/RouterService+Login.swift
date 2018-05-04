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
import RxFeedback
import Apollo

extension RouterService {
    
    enum Login {}
}

extension RouterService.Login {
    
    static func loginViewController(client: ApolloClient, store: AppStore) -> LoginViewController {
        let dependency = DriverFeedback<LoginState>.system(client: client, store: store)
        return LoginViewController(dependency: dependency)
    }
}
