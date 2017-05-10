//
//  WebViewController.swift
//  EasyReader
//
//  Created by Oleg Gorelov on 10.05.17.
//  Copyright © 2017 Oleg Gorelov. All rights reserved.
//

import UIKit

class WebViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView! {
        didSet {
            webView.delegate = self
        }
    }
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var itemLink: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    private func setupUI() {
        
        if itemLink != nil, let url = URL(string: itemLink!) {
            
            let urlRequest = URLRequest(url: url)
            webView.loadRequest(urlRequest)
            
        }
        
    }
    
    // MARK: - UIWebViewDelegate
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        activityIndicator.startAnimating()
    }

    func webViewDidFinishLoad(_ webView: UIWebView) {
        activityIndicator.stopAnimating()
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        activityIndicator.stopAnimating()
    }
}
