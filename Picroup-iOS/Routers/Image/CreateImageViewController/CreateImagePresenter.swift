//
//  CreateImagePresenter.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/22.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import Material

class CreateImagePresenter: NSObject {
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet { prepareCollectionView() }
    }
    @IBOutlet weak var tagsCollectionView: UICollectionView! {
        didSet {
            (tagsCollectionView.collectionViewLayout as! UICollectionViewFlowLayout)
                .estimatedItemSize = CGSize(width: 44, height: 22)
            tagsCollectionView.register(UINib(nibName: "TagCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TagCollectionViewCell")
        }
    }
    @IBOutlet weak var addTagTextField: UITextField!
        @IBOutlet weak var saveButton: RaisedButton!
    @IBOutlet weak var progressView: ProgressView!
    
    let didCommitTag = PublishRelay<String>()
    
    private func prepareCollectionView() {
        collectionView.register(UINib(nibName: "RankMediumCell", bundle: nil), forCellWithReuseIdentifier: "RankMediumCell")
    }
    
}

extension Reactive where Base: ProgressView {
    var progress: Binder<Float> {
        return Binder(self.base) { progressView, progress in
            progressView.progress = progress
        }
    }
}

extension CreateImagePresenter: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard textField == addTagTextField else { return true }
        if addTagTextField.text == nil || addTagTextField.text!.isEmpty {
            textField.resignFirstResponder()
            return true
        } else if let tag = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines), tag.matchExpression(RegularPattern.tag) {
            didCommitTag.accept(tag)
            addTagTextField.text = ""
            textField.resignFirstResponder()
            return true
        }
        return false
    }
}
