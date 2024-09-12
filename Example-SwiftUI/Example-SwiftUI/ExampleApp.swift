//
//  ExampleApp.swift
//  Example-SwiftUI
//
//  Created by Mathew Gacy on 10/19/22.
//  Copyright © 2022 Blue Triangle. All rights reserved.
//

import BlueTriangle
import SwiftUI
import UIKit

@main
struct Example_SwiftUIApp: App {
    @State private var  BttContainer =  BTTRootContrainerView(vm: BTTConfigModel())
    @Environment(\.scenePhase) private var scenePhase
    
    init() {
        ConfigurationSetup.configOnLaunch()
        ConfigurationSetup.addDelay()
    }
    
    
    var body: some Scene {
        WindowGroup {
            self.BttContainer
        }
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .active:
                ConfigurationSetup.updateSessionId()
                ConfigurationSetup.addDelay()
                print("Active")
            case .background:
                print("In Background")
               //SessionStore.updateSessionExpiry()
            case .inactive:
                print("Inactive")
            @unknown default: break
            }
        }
    }
}

