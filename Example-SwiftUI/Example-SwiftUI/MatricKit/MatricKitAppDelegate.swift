//
//  MatricKitAppDelegate.swift
//
//  Apple recommends registering the MetricKit subscriber as early as possible
//  in the app's lifecycle, so MetricKitManager.shared is touched here rather
//  than lazily from a view. Also honors the "Arm Slow Launch" trigger from
//  the MatricKit Triggers section, which needs a cold-launch hook to work.

import UIKit

final class MatricKitAppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        _ = MetricKitManager.shared
        LaunchHistory.recordColdLaunch()
        if let delay = StressSimulators.slowLaunchDelayIfArmed() {
            Thread.sleep(forTimeInterval: delay)
        }
        return true
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        return true
    }
}
