//
//  ViewController.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/3/19.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import Apollo

class ViewController: UIViewController {

    private let client = ApolloClient(url: URL(string: "http://home.beeth0ven.cf:3000/graphql")!)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _ = client.fetch(query: BooksQuery()) { (result, error) in
            guard error == nil else {
                print("error: \(error!)")
                return
            }
            print("result: \(result!)")
        }
    }

}

