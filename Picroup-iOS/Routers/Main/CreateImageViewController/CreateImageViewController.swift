//
//  CreateImageViewController.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/11.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import Material
import RxSwift
import RxCocoa

class CreateImageViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cancelButton: RaisedButton!
    @IBOutlet weak var saveButton: RaisedButton!
    
    var image: UIImage!
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.image = image
        
        Signal.merge(cancelButton.rx.tap.asSignal(), saveButton.rx.tap.asSignal())
            .emit(to: rx.dismiss(animated: true))
            .disposed(by: disposeBag)
        
    }
}
