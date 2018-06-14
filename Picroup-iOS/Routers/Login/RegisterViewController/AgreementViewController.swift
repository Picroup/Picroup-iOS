//
//  AboutAppViewController.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/6/12.
//  Copyright © 2018年 luojie. All rights reserved.
//
import UIKit

///用户协议
class AgreementViewController: BaseViewController {
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
}

extension AgreementViewController: UIWebViewDelegate {
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        spinner.startAnimating()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        spinner.stopAnimating()
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        spinner.stopAnimating()
    }
}
