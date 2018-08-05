//
//  UpdateMediumTagsPresenter.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/7/11.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import Material

final class UpdateMediumTagsPresenter: NSObject {

    @IBOutlet weak var tagsCollectionView: UICollectionView! {
        didSet {
            (tagsCollectionView.collectionViewLayout as! UICollectionViewFlowLayout)
                .estimatedItemSize = CGSize(width: 44, height: 22)
        }
    }
    @IBOutlet weak var addTagTextField: UITextField!
    
    let didCommitTag = PublishRelay<String>()
}

extension UpdateMediumTagsPresenter: UITextFieldDelegate {
    
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
