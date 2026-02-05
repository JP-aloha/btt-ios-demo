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
    @State private var  BttContainer =  BTTRootContrainerView(coordinatorVm: AppCoordinator(), vm: BTTConfigModel())
    @Environment(\.scenePhase) private var scenePhase
    
    init() {
        ConfigurationSetup.configOnLaunch()
        ConfigurationSetup.addDelay()
        BlueTriangle.trafficSegmentName = "iOS-SwiftUI-eComDemo"
        BlueTriangle.setCampaignName("iOS")
        BlueTriangle.setCampaignMedium("Device")
        BlueTriangle.setCampaignSource("SwiftUI")
        BlueTriangle.setDataCenter("NorthEast-1")
        BlueTriangle.setAbTestID("Mardern-UI")
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
               SessionStore.updateSessionExpiry()
            case .inactive:
                print("Inactive")
            @unknown default: break
            }
        }
    }
}

