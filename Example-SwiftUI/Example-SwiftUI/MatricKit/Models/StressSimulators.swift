import Foundation
import UIKit

/// Deliberate, bounded stress conditions used to provoke each MetricKit
/// metric/diagnostic category from a single tap. Diagnostic categories
/// (hang/CPU exception/disk write exception) generally require the OS to
/// observe a sustained pattern on a real device, so a single trigger mainly
/// feeds the corresponding *metric*; repeat them over time on-device to see
/// the matching diagnostic appear.
enum StressSimulators {
    static let armSlowLaunchKey = "MatricKitPoc.ArmSlowLaunch"
    static let slowLaunchDelayKey = "MatricKitPoc.SlowLaunchDelay"

    /// Sets a flag AppDelegate checks on the next cold launch, blocking startup
    /// long enough for iOS to log an excessive-launch-duration diagnostic
    /// (MXAppLaunchDiagnostic). Only takes effect after a full force-quit + relaunch —
    /// MetricKit generally won't collect anything while Xcode's debugger is attached,
    /// so relaunch from the home screen icon, not Xcode's Run button.
    static func armSlowLaunch(delay: TimeInterval) {
        UserDefaults.standard.set(true, forKey: armSlowLaunchKey)
        UserDefaults.standard.set(delay, forKey: slowLaunchDelayKey)
    }

    /// Consumes the armed flag (if set) and returns the delay to sleep for.
    /// Called once from AppDelegate at cold launch.
    static func slowLaunchDelayIfArmed() -> TimeInterval? {
        guard UserDefaults.standard.bool(forKey: armSlowLaunchKey) else { return nil }
        UserDefaults.standard.removeObject(forKey: armSlowLaunchKey)
        let delay = UserDefaults.standard.double(forKey: slowLaunchDelayKey)
        return delay > 0 ? delay : 5
    }

    /// Pins every available core near 100% for `duration`. Real MXCPUExceptionDiagnostic
    /// thresholds are about sustained *cumulative* CPU time, so this deliberately spins
    /// concurrently across all cores rather than a single thread, and defaults to a much
    /// longer duration than a quick UI demo would normally use.
    static func cpuSpin(duration: TimeInterval, completion: @escaping () -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let deadline = Date().addingTimeInterval(duration)
            var accumulator: Double = 0
            while Date() < deadline {
                for i in 0..<100_000 {
                    accumulator += sin(Double(i)) * cos(Double(i))
                }
            }
            _ = accumulator
            DispatchQueue.main.async(execute: completion)
        }
    }

    /// `MXCPUExceptionDiagnostic` is tied to the OS killing an app for abusing CPU
    /// *while backgrounded* — not to bounded foreground spins like `cpuSpin` above.
    /// This claims a background execution grant and keeps every core near 100%
    /// for as long as the system allows (or 90s, whichever is shorter), so it only
    /// does something meaningful if you background the app right after tapping.
    static func cpuSpinInBackground(completion: @escaping (TimeInterval) -> Void) {
        var backgroundTask: UIBackgroundTaskIdentifier = .invalid
        backgroundTask = UIApplication.shared.beginBackgroundTask(withName: "MatricKitPoc.CPUAbuse") {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }

        DispatchQueue.global(qos: .userInitiated).async {
            let start = Date()
            var accumulator: Double = 0
            while Date().timeIntervalSince(start) < 90 && UIApplication.shared.backgroundTimeRemaining > 1 {
                for i in 0..<100_000 {
                    accumulator += sin(Double(i)) * cos(Double(i))
                }
            }
            _ = accumulator
            let elapsed = Date().timeIntervalSince(start)
            DispatchQueue.main.async {
                if backgroundTask != .invalid {
                    UIApplication.shared.endBackgroundTask(backgroundTask)
                    backgroundTask = .invalid
                }
                completion(elapsed)
            }
        }
    }

    /// Intentionally blocks the calling (main) thread so the OS can observe
    /// an app hang for MXAppResponsivenessMetric / MXHangDiagnostic.
    static func hangMainThread(duration: TimeInterval) {
        Thread.sleep(forTimeInterval: duration)
    }
    
    /// Blocks the main thread indefinitely — the app becomes fully unresponsive
    /// and must be force-quit. Useful for provoking the OS's harshest hang
    /// classification instead of the bounded hangs above.
    static func hangMainThreadForever() {
        DispatchSemaphore(value: 0).wait()
    }

    /// Writes large files continuously for `duration`. Real MXDiskWriteExceptionDiagnostic
    /// thresholds are about total write *volume*, so this uses much bigger chunks than a
    /// token demo write, and keeps files (doesn't delete mid-run) so writes actually land.
    static func diskChurn(duration: TimeInterval, completion: @escaping () -> Void) {
        DispatchQueue.global(qos: .utility).async {
            let fileManager = FileManager.default
            let directory = fileManager.temporaryDirectory.appendingPathComponent("MatricKitPocDiskChurn", isDirectory: true)
            try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
            let payload = Data(repeating: 0xAB, count: 10_000_000)
            let deadline = Date().addingTimeInterval(duration)
            var counter = 0
            while Date() < deadline {
                let url = directory.appendingPathComponent("chunk-\(counter % 10).bin")
                try? payload.write(to: url, options: .atomic)
                counter += 1
            }
            try? fileManager.removeItem(at: directory)
            DispatchQueue.main.async(execute: completion)
        }
    }

    /// `MXDiskWriteExceptionDiagnostic` is, like the CPU exception above, tied to
    /// the OS killing an app for excessive disk writes *while backgrounded*. Same
    /// background-execution-grant approach as `cpuSpinInBackground`.
    static func diskChurnInBackground(completion: @escaping (TimeInterval) -> Void) {
        var backgroundTask: UIBackgroundTaskIdentifier = .invalid
        backgroundTask = UIApplication.shared.beginBackgroundTask(withName: "MatricKitPoc.DiskAbuse") {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }

        DispatchQueue.global(qos: .utility).async {
            let start = Date()
            let fileManager = FileManager.default
            let directory = fileManager.temporaryDirectory.appendingPathComponent("MatricKitPocBackgroundDiskAbuse", isDirectory: true)
            try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
            let payload = Data(repeating: 0xAB, count: 10_000_000)
            var counter = 0
            while Date().timeIntervalSince(start) < 90 && UIApplication.shared.backgroundTimeRemaining > 1 {
                let url = directory.appendingPathComponent("chunk-\(counter % 20).bin")
                try? payload.write(to: url, options: .atomic)
                counter += 1
            }
            try? fileManager.removeItem(at: directory)
            let elapsed = Date().timeIntervalSince(start)
            DispatchQueue.main.async {
                if backgroundTask != .invalid {
                    UIApplication.shared.endBackgroundTask(backgroundTask)
                    backgroundTask = .invalid
                }
                completion(elapsed)
            }
        }
    }

    static func networkTransfer(completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "https://httpbin.org/bytes/200000") else {
            completion(false)
            return
        }
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async {
                completion(error == nil && data != nil)
            }
        }
        task.resume()
    }

    /// Force-quits the app so the OS can generate an MXCrashDiagnostic on next launch.
    static func triggerCrash() {
        fatalError("MatricKitPoc: user-triggered test crash to exercise MXCrashDiagnostic.")
    }
}
