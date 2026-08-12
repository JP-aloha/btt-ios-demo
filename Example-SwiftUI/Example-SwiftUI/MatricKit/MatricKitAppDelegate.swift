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
        if let armed = StressSimulators.slowLaunchDelayIfArmed(at: .willFinishLaunching) {
            StressSimulators.applySlowLaunchDelay(armed.delay, method: armed.method)
        }
        return true
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        _ = MetricKitManager.shared
        if let armed = StressSimulators.slowLaunchDelayIfArmed(at: .didFinishLaunching) {
            StressSimulators.applySlowLaunchDelay(armed.delay, method: armed.method)
        }
        return true
    }
}
