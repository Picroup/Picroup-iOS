//
//  ViewController.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/3/19.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import Apollo
import Kingfisher
import RxSwift

class ViewController: UIViewController {

    @IBOutlet private weak var spinner: UIActivityIndicatorView!
    @IBOutlet private weak var uploadButton: UIButton!
    private let disposeBag = DisposeBag()
    
//    private let client = ApolloClient(url: URL(string: "\(Config.baseURL)/graphql")!)

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        _ = client.fetch(query: BooksQuery()) { (result, error) in
//            guard error == nil else {
//                print("error: \(error!)")
//                return
//            }
//            print("result: \(result!)")
//        }
    }
    
    @IBAction func uploadImage(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.presentingViewController?.dismiss(animated: true)
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let spinner = self.spinner!
            let uploadButton = self.uploadButton!
            
            spinner.startAnimating()
            
            let (progress, filename) = ImageUpoader.uploadImage(image)
            progress.observeOn(MainScheduler.instance)
                .map { $0.completed }
                .subscribe(onNext: { (progress) in
                    print("onNext", progress)
                }, onError: { (error) in
                    print("onError", error)
                }, onCompleted: {
                    print("onCompleted")
                    let imageURL = URL(string: "\(Config.baseURL)/s3?name=\(filename)")!
                    _ = uploadButton.kf.setBackgroundImage(with: imageURL, for: .normal)
                }, onDisposed: {
                    print("onDisposed")
                    spinner.stopAnimating()
                }).disposed(by: disposeBag)
        }
    }
}
