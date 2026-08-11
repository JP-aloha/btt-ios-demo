import Foundation
import UIKit

enum StressSimulators {
    static let armSlowLaunchKey = "MatricKitPoc.ArmSlowLaunch"
    static let slowLaunchDelayKey = "MatricKitPoc.SlowLaunchDelay"

    static func armSlowLaunch(delay: TimeInterval) {
        UserDefaults.standard.set(true, forKey: armSlowLaunchKey)
        UserDefaults.standard.set(delay, forKey: slowLaunchDelayKey)
    }

    static func slowLaunchDelayIfArmed() -> TimeInterval? {
        guard UserDefaults.standard.bool(forKey: armSlowLaunchKey) else { return nil }
        UserDefaults.standard.removeObject(forKey: armSlowLaunchKey)
        let delay = UserDefaults.standard.double(forKey: slowLaunchDelayKey)
        return delay > 0 ? delay : 5
    }

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

    static func hangMainThread(duration: TimeInterval) {
        Thread.sleep(forTimeInterval: duration)
    }
    
    static func hangMainThreadForever() {
        DispatchSemaphore(value: 0).wait()
    }

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

    static func triggerCrash() {
        fatalError("MatricKitPoc: user-triggered test crash to exercise MXCrashDiagnostic.")
    }

    private static let hangThreshold: TimeInterval = 0.75

    /// Only every `hitchEveryNthRow`th row pays the hitch cost — the rest
    /// render at negligible cost so the list stays scrollable, with real
    /// hitches sprinkled in often enough to be detectable rather than a
    /// wall-to-wall main-thread block on every single row.
    private static let hitchEveryNthRow = 3

    /// Order History rows: every `hitchEveryNthRow`th cell blocks the
    /// calling thread briefly (well under the hang threshold); the rest are
    /// effectively free. Scrolling stays usable while still producing real
    /// per-frame hitches — this screen exercises only hitch-rate detection,
    /// never a hang.
    static func hitchOnlyCellImage(index: Int, size: CGSize = CGSize(width: 60, height: 60)) -> UIImage {
        let duration: TimeInterval = index % hitchEveryNthRow == 0 ? .random(in: 0.02...0.06) : 0
        return drawBusyImage(index: index, duration: duration, size: size)
    }

    /// Favourite rows: same light hitch cadence as Order History, but every
    /// `hangEveryNthRow`th row blocks past the hang threshold instead — kept
    /// infrequent so the list is still scrollable between hangs, while
    /// exercising both hitch-rate tracking and hang diagnostics.
    static func hitchOrHangCellImage(index: Int, size: CGSize = CGSize(width: 60, height: 60)) -> UIImage {
        let hangEveryNthRow = 20
        let isHangRow = index > 0 && index % hangEveryNthRow == 0
        let isHitchRow = index % hitchEveryNthRow == 0

        let duration: TimeInterval
        if isHangRow {
            duration = .random(in: (hangThreshold + 0.05)...(hangThreshold + 0.25))
        } else if isHitchRow {
            duration = .random(in: 0.02...0.06)
        } else {
            duration = 0
        }
        return drawBusyImage(index: index, duration: duration, size: size)
    }

    private static func drawBusyImage(index: Int, duration: TimeInterval, size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            let cgContext = context.cgContext

            // Distinct base color per row so every cell is visibly different
            // at a glance, not just a subtly different noise field.
            let hue = CGFloat(index % 36) / 36.0
            UIColor(hue: hue, saturation: 0.55, brightness: 0.95, alpha: 1).setFill()
            cgContext.fill(CGRect(origin: .zero, size: size))

            let deadline = Date().addingTimeInterval(duration)
            var i = 0
            while Date() < deadline {
                let shapeHue = CGFloat((index + i) % 360) / 360.0
                UIColor(hue: shapeHue, saturation: 0.75, brightness: 0.9, alpha: 0.06).setFill()
                let x = CGFloat((index * 7 + i * 13) % Int(size.width))
                let y = CGFloat((index * 11 + i * 17) % Int(size.height))
                let radius = CGFloat(2 + (i % 6))
                cgContext.fillEllipse(in: CGRect(x: x, y: y, width: radius, height: radius))
                i += 1
            }

            // Row number stamped on top, so cells are unmistakably distinct
            // even at a glance rather than only differing pixel-for-pixel.
            let text = "#\(index)" as NSString
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 16),
                .foregroundColor: UIColor.white,
                .strokeColor: UIColor.black,
                .strokeWidth: -3
            ]
            let textSize = text.size(withAttributes: attributes)
            let textRect = CGRect(
                x: (size.width - textSize.width) / 2,
                y: (size.height - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )
            text.draw(in: textRect, withAttributes: attributes)
        }
    }
}
