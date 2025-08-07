//
//  Untitled.swift
//
//  Created by Ashok Singh on 07/08/25.
//  Copyright © 2025 Blue Triangle. All rights reserved.
//

import UIKit
import BlueTriangle

class TutorialPageViewController: UIViewController {
    @IBOutlet weak var lblTitle : UILabel!
    @IBOutlet weak var lblDesc : UILabel!
    private var model : TutorialPageModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateUI()
    }
    
    private func updateUI(){
        lblTitle.text = model?.title
        lblDesc.text =  model?.desc
    }
    
    static func getPageSlides()-> [TutorialPageViewController] {
        let page1 = getPageForTitle("Welcome to Ecom Demo App", desc: """
This app is built for testing out the features of the Blue Triangle SDK for Android/iOS.

It has built-in support for generating scenarios to test features such as:

    . Screen Tracking  
    . Crash Tracking  
    . ANR Detection

and more...
""")
        let page2 = getPageForTitle("Screen Tracking", desc: "The Blue Triangle SDK automatically tracks all screens for UIKit, for SwiftUI the app screens have manually been tagged to be tracked by the SDK. Just browse through different screens, perform checkouts, etc that will generate some page views.")
        let page3 = getPageForTitle("Crash Tracking", desc: """
There are two scenarios for generating a crash in this app.

Scenario 1: Empty Cart Checkout  
    . A checkout without any products in the cart would simulate a crash.

Scenario 2: Cart Overflow  
    . Adding 5 or more distinct products to the cart and performing a checkout operation would result in a crash.

Note: The crash will be captured and stored locally until the next launch of the app, when it will be submitted to the backend servers.
""")
        let page4 = getPageForTitle("ANR Detection", desc: """
Application Not Responding (ANR) is a state when the app is unresponsive for a significant amount of time. The Blue Triangle SDK tracks such states and reports it. This app has some manufactured ANR scenarios built in.

Scenario 1: Remove a Product from Cart  
    . Add a product to the cart and then try removing it using the trash icon. That will result in the app getting hanged for several seconds resulting in an ANR state which will be reported.

Scenario 2: Continue Shopping  
    . Add some products to the cart and perform a checkout. A checkout confirmation screen appears with a "Continue Shopping" button. Clicking on it will result in the app getting into an ANR state.
""")
        return [page1, page2, page3, page4]
    }
    
    static func getPageForTitle(_ title : String, desc : String)-> TutorialPageViewController {
        let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
        let page = storyBoard.instantiateViewController(withIdentifier: String(describing: TutorialPageViewController.self)) as! TutorialPageViewController
        page.model = TutorialPageModel(title: title, desc: desc)
        return page
    }
}

struct TutorialPageModel {
    let title : String
    let desc : String
}
