//
//  TutorialView.swift
//
//  Created by Ashok Singh on 07/08/25.
//  Copyright © 2025 Blue Triangle. All rights reserved.
//

import SwiftUI

struct TutorialView: View {
    @ObservedObject var vm: AppCoordinator
    @Environment(\.dismiss) private var dismiss
    @State private var currentPage = 0

    var body: some View {
        NavigationStack {
            VStack {
                TabView(selection: $currentPage) {
                    ForEach(Array(slides.enumerated()), id: \.offset) { index, slide in
                        TutorialPageView(model: slide)
                            .tag(index)
                            .padding()
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                .animation(.easeInOut, value: currentPage)
            }
            .navigationTitle("Tutorial")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                        UserDefaults.standard.set(true, forKey: UserDefaultKeys.TutorialShownKey)
                        UserDefaults.standard.synchronize()
                        vm.isShownTutorial.toggle()
                    }
                }
            }
        }
    }
    
    private let slides: [TutorialPageModel] = [
        .init(title: "Welcome to Ecom Demo App", desc: """
This app is built for testing out the features of the Blue Triangle SDK for Android/iOS.

It has built-in support for generating scenarios to test features such as:

    . Screen Tracking  
    . Crash Tracking  
    . ANR Detection

and more...
""", iconName: "hand.wave.fill"),
        .init(title: "Screen Tracking", desc: """
The Blue Triangle SDK automatically tracks all screens for UIKit, for SwiftUI the app screens have manually been tagged to be tracked by the SDK. Just browse through different screens, perform checkouts, etc that will generate some page views.
""", iconName:  "eye.fill"),
        .init(title: "Crash Tracking", desc: """
There are two scenarios for generating a crash in this app.

Scenario 1: Empty Cart Checkout  
    . A checkout without any products in the cart would simulate a crash.
Scenario 2: Cart Overflow  
    . Adding 5 or more distinct products to the cart and performing a checkout operation would result in a crash.

Note: The crash will be captured and stored locally until the next launch of the app, when it will be submitted to the backend servers.
""", iconName: "exclamationmark.triangle.fill"),
        .init(title: "ANR Detection", desc: """
Application Not Responding (ANR) is a state when the app is unresponsive for a significant amount of time. The Blue Triangle SDK tracks such states and reports it. This app has some manufactured ANR scenarios built in.
Scenario 1: Remove a Product from Cart  
    . Add a product to the cart and then try removing it using the trash icon. That will result in the app getting hanged for several seconds resulting in an ANR state which will be reported.
Scenario 2: Continue Shopping  
    . Add some products to the cart and perform a checkout. A checkout confirmation screen appears with a "Continue Shopping" button. Clicking on it will result in the app getting into an ANR state.
""", iconName: "timer")
    ]
}

struct TutorialPageModel: Identifiable {
    let id = UUID()
    let title: String
    let desc: String
    let iconName: String?
}
