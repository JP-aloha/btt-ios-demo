//
//  BttWebViewController.swift
//
//  Created by Ashok Singh on 22/12/23.
//  Copyright © 2023 Blue Triangle. All rights reserved.
//

import UIKit
import WebKit
import BlueTriangle

class BttWebViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    private let model = HybridViewModel()
    var tagUrl : String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
		/*
        if #available(iOS 16.4, *) {
            webView.isInspectable = true
        } else {
            // Fallback on earlier versions
        }
		 */
        webView.navigationDelegate = self
        webView.configuration.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        loadWebView()
    }
    
    func loadWebView() {
        
        guard let url = model.getTemplateUrl(tagUrl) else {
             return
        }

        webView.load(URLRequest(url: url))
    }
    
    @IBAction func didSelectFinish(_ sender: Any?) {
        self.dismiss(animated: true)
    }
    
    @IBAction func didSelectQuestion(_ sender: Any?) {
        HybridViewModel.showDocInfo()
    }
}

extension BttWebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        BTTWebViewTracker.webView(webView, didCommit: navigation)
    }
}
