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
		
        if #available(iOS 16.4, *) {
            webView.isInspectable = true
        } else {
            // Fallback on earlier versions
        }
        webView.navigationDelegate = self
        webView.configuration.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        loadWebView()
    }
    
    func loadWebView() {
        
        guard let url = model.getTemplateUrl(tagUrl) else {
             return
        }

        if let urlNew = URL.init(string: "http://192.168.1.126:5173") {
            webView.load(URLRequest(url: urlNew))
        }
    }
    
    @IBAction func didSelectFinish(_ sender: Any?) {
        self.dismiss(animated: true)
    }
    
    @IBAction func didSelectQuestion(_ sender: Any?) {
        HybridViewModel.showDocInfo()
    }
    
    func makeSPAInjectionScript() -> WKUserScript {
        let script = """
        (function() {
            function notify() {
                window.webkit.messageHandlers.urlChanged.postMessage(window.location.href);
            }

            const pushState = history.pushState;
            history.pushState = function() {
                pushState.apply(history, arguments);
                notify();
            };

            const replaceState = history.replaceState;
            history.replaceState = function() {
                replaceState.apply(history, arguments);
                notify();
            };

            window.addEventListener('popstate', notify);

            // hash change (important!)
            window.addEventListener('hashchange', notify);

            // initial load
            notify();
        })();
        """

        return WKUserScript(
            source: script,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: false   // 👈 important for iframe cases
        )
    }
}

extension BttWebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
       // print("Finished loading: \(webView.url?.absoluteString ?? "")")
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("Finished loading: \(webView.url?.absoluteString ?? "")")
         BTTWebViewTracker.webView(webView, didCommit: navigation)
    }
    
    // Called when navigation starts
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("Started loading: \(webView.url?.absoluteString ?? "")")
    }
    // Called before navigation (decision point)
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        print("Navigating to: \(navigationAction.request.url?.absoluteString ?? "")")
        decisionHandler(.allow)
    }
}
