import Foundation

/// Tracks how many undisturbed cold launches this install has accumulated.
/// MXAppLaunchDiagnostic flags a launch as "slow" relative to this device's
/// own launch-time history for the app — reinstalling (including a fresh
/// Xcode install over the old build) resets that history back to zero.
enum LaunchHistory {
    private static let firstLaunchKey = "MatricKitPoc.FirstLaunchDate"
    private static let countKey = "MatricKitPoc.LaunchCount"

    @discardableResult
    static func recordColdLaunch() -> Int {
        let defaults = UserDefaults.standard
        if defaults.object(forKey: firstLaunchKey) == nil {
            defaults.set(Date(), forKey: firstLaunchKey)
        }
        let count = defaults.integer(forKey: countKey) + 1
        defaults.set(count, forKey: countKey)
        return count
    }

    static var firstLaunchDate: Date? {
        UserDefaults.standard.object(forKey: firstLaunchKey) as? Date
    }

    static var launchCount: Int {
        UserDefaults.standard.integer(forKey: countKey)
    }
}
