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
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tagsCollectionView: UICollectionView! {
        didSet {
            (tagsCollectionView.collectionViewLayout as! UICollectionViewFlowLayout)
                .estimatedItemSize = CGSize(width: 44, height: 22)
        }
    }
    @IBOutlet weak var addTagTextField: UITextField!
        @IBOutlet weak var saveButton: RaisedButton!
    @IBOutlet weak var progressView: UIProgressView!
    
    let didCommitTag = PublishRelay<String>()
}

extension CreateImagePresenter: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CollectionViewLayoutManager.size(in: collectionView.bounds)
//    }
}

final class TagCollectionViewCell: RxCollectionViewCell {
    @IBOutlet weak var tagLabel: UILabel!
    
    func setSelected(_ selected: Bool) {
        backgroundColor = selected ? .primaryLight : .secondaryLightText
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
