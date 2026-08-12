//
//  AppDelegate.swift
//
//  Created by Admin on 21/06/23.
//  Copyright © 2023 Blue Triangle. All rights reserved.
//

import UIKit
import BlueTriangle

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    override init() {
        super.init()
        _ = MetricKitManager.shared
        if let armed = StressSimulators.slowLaunchDelayIfArmed(at: .appInit) {
            StressSimulators.applySlowLaunchDelay(armed.delay, method: armed.method)
        }
    }

    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        _ = MetricKitManager.shared
        if let armed = StressSimulators.slowLaunchDelayIfArmed(at: .willFinishLaunching) {
            StressSimulators.applySlowLaunchDelay(armed.delay, method: armed.method)
        }
        return true
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        ConfigurationSetup.configOnLaunch()
        ConfigurationSetup.addDelay()
        BlueTriangle.trafficSegmentName = "iOS-UIKit-eComDemo"
        BlueTriangle.setCampaignName("iOS")
        BlueTriangle.setCampaignMedium("Device")
        BlueTriangle.setCampaignSource("UIKIT")
        BlueTriangle.setDataCenter("NorthWest-1")
        BlueTriangle.setAbTestID("Lagacy-UI")

        _ = MetricKitManager.shared
        LaunchHistory.recordColdLaunch()
        if let armed = StressSimulators.slowLaunchDelayIfArmed(at: .didFinishLaunching) {
            StressSimulators.applySlowLaunchDelay(armed.delay, method: armed.method)
        }

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
    }


}

