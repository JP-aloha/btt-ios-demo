//
//  BttWebView.swift
//
//  Created by Ashok Singh on 18/01/24.
//  Copyright © 2024 Blue Triangle. All rights reserved.
//

import SwiftUI
import WebKit
import BlueTriangle

struct BttWebView: UIViewRepresentable {
   
    var tagUrl : String
    private let model = HybridViewModel()
    private let webView = WKWebView()
    
    func makeCoordinator() -> BttWebView.Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> some UIView {
        
        if let htmlURL = model.getTemplateUrl(tagUrl){
			/*
            if #available(iOS 16.4, *) {
                webView.isInspectable = true
            } else {
                // Fallback on earlier versions
            }
			*/
            webView.configuration.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
            webView.navigationDelegate = context.coordinator
            webView.load(URLRequest(url: htmlURL))
        }
        return webView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
    }
}

extension BttWebView {
   
    class Coordinator: NSObject, WKNavigationDelegate {
   
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        }
        
        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            BTTWebViewTracker.webView(webView, didCommit: navigation)
        }
        
        func webView(_ webView: WKWebView,
                     decidePolicyFor navigationResponse: WKNavigationResponse,
                     decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
            
            decisionHandler(.allow)
        }
    }
}
