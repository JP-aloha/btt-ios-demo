//
//  FramesTracker.swift
//
//  Revision informed by inspecting Sentry's real SentryFramesTracker
//  implementation. Key corrections vs. the first draft:
//
//   1. Slow-frame threshold is derived from the *measured* refresh rate each
//      frame (not a cached link.duration), rounded to the nearest fps, with
//      one frame's headroom subtracted — otherwise normal microsecond jitter
//      flags nearly every frame as "slow".
//   2. No NSHashTable for weak listeners — it can be mutated mid-iteration
//      from a concurrent dealloc, which is a real crash class. All mutation
//      is funneled onto the main queue instead (where the display link
//      callback also runs), so there's nothing to race against.
//   3. Pause/resume tracks app *active* state (didBecomeActive/
//      willResignActive), not just background/foreground.
//   4. Per-span metrics are a *windowed query* against a rolling log of
//      delayed-frame intervals, not a listener callback. A span just
//      remembers its own start/end timestamp and asks "how much delay
//      happened between these two points?" — no registration lifecycle.
//
//  Original implementation, written from scratch — not copied source.
//

import QuartzCore
import UIKit

// MARK: - Delay log entry

private struct DelayedFrame {
    let startTimestamp: CFTimeInterval
    let endTimestamp: CFTimeInterval
    let delay: CFTimeInterval
}

private final class DelayedFramesLog {
    private var entries: [DelayedFrame] = []
    private let maxAge: CFTimeInterval = 300

    func record(start: CFTimeInterval, end: CFTimeInterval, delay: CFTimeInterval) {
        entries.append(DelayedFrame(startTimestamp: start, endTimestamp: end, delay: delay))
        trim(now: end)
    }

    private func trim(now: CFTimeInterval) {
        entries.removeAll { now - $0.endTimestamp > maxAge }
    }

    func delay(from start: CFTimeInterval, to end: CFTimeInterval) -> CFTimeInterval {
        guard end > start else { return 0 }
        var total: CFTimeInterval = 0
        for entry in entries {
            let overlapStart = max(entry.startTimestamp, start)
            let overlapEnd = min(entry.endTimestamp, end)
            guard overlapEnd > overlapStart else { continue }
            let frameSpan = entry.endTimestamp - entry.startTimestamp
            guard frameSpan > 0 else { continue }
            let overlapFraction = (overlapEnd - overlapStart) / frameSpan
            total += entry.delay * overlapFraction
        }
        return total
    }
}

// MARK: - Shared tracker

public final class FramesTracker {

    public static let shared = FramesTracker()

    private static let frozenFrameThreshold: CFTimeInterval = 0.7
    private static let previousFrameInitialValue: CFTimeInterval = -1

    private var displayLink: CADisplayLink?
    private var previousFrameTimestamp: CFTimeInterval = FramesTracker.previousFrameInitialValue
    private var isStarted = false
    private var isActive = false
    private let delayLog = DelayedFramesLog()

    // MARK: Public counts — each its own var

    public private(set) var totalFrameCount: UInt = 0
    public private(set) var slowFrameCount: UInt = 0
    public private(set) var frozenFrameCount: UInt = 0

    private init() {}

    // MARK: Lifecycle

    public func start() { runOnMain { self.startInternal() } }
    public func stop() { runOnMain { self.stopInternal() } }

    private func startInternal() {
        guard !isStarted else { return }
        isStarted = true
        NotificationCenter.default.addObserver(
            self, selector: #selector(didBecomeActive),
            name: UIApplication.didBecomeActiveNotification, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(willResignActive),
            name: UIApplication.willResignActiveNotification, object: nil
        )
        unpause()
    }

    private func stopInternal() {
        guard isStarted else { return }
        isStarted = false
        pause()
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func didBecomeActive() { runOnMain { self.unpause() } }
    @objc private func willResignActive() { runOnMain { self.pause() } }

    private func unpause() {
        guard !isActive else { return }
        isActive = true
        previousFrameTimestamp = Self.previousFrameInitialValue
        let link = CADisplayLink(target: self, selector: #selector(displayLinkCallback))
        link.add(to: .main, forMode: .common)
        displayLink = link
    }

    private func pause() {
        isActive = false
        displayLink?.invalidate()
        displayLink = nil
    }

    private func runOnMain(_ work: @escaping () -> Void) {
        if Thread.isMainThread { work() } else { DispatchQueue.main.async(execute: work) }
    }

    // MARK: Core tick

    @objc private func displayLinkCallback() {
        guard let link = displayLink else { return }
        let thisFrameTimestamp = link.timestamp

        guard previousFrameTimestamp != Self.previousFrameInitialValue else {
            previousFrameTimestamp = thisFrameTimestamp
            return
        }

        var currentFrameRate: UInt64 = 60
        if link.targetTimestamp != link.timestamp {
            currentFrameRate = UInt64((1 / (link.targetTimestamp - link.timestamp)).rounded())
        }
        let slowThreshold = Self.slowFrameThreshold(currentFrameRate)
        let frameDuration = thisFrameTimestamp - previousFrameTimestamp

        if frameDuration > slowThreshold && frameDuration <= Self.frozenFrameThreshold {
            slowFrameCount += 1
            delayLog.record(start: previousFrameTimestamp, end: thisFrameTimestamp,
                             delay: frameDuration - slowThreshold)
        } else if frameDuration > Self.frozenFrameThreshold {
            frozenFrameCount += 1
            delayLog.record(start: previousFrameTimestamp, end: thisFrameTimestamp,
                             delay: frameDuration - slowThreshold)
        }

        totalFrameCount += 1
        previousFrameTimestamp = thisFrameTimestamp
    }

    private static func slowFrameThreshold(_ actualFramesPerSecond: UInt64) -> CFTimeInterval {
        guard actualFramesPerSecond > 1 else { return frozenFrameThreshold }
        return 1.0 / CFTimeInterval(actualFramesPerSecond - 1)
    }

    // MARK: Public query functions — each returns its own value

    /// Total delay, in seconds, between two CACurrentMediaTime timestamps.
    public func framesDelay(from start: CFTimeInterval, to end: CFTimeInterval) -> CFTimeInterval {
        delayLog.delay(from: start, to: end)
    }

    /// Milliseconds of hitching per second, for the given window.
    public func hitchRate(from start: CFTimeInterval, to end: CFTimeInterval) -> Double {
        let duration = end - start
        guard duration > 0 else { return 0 }
        return (framesDelay(from: start, to: end) / duration) * 1000
    }
}

/*
 USAGE:

 FramesTracker.shared.start()

 // read counts any time:
 FramesTracker.shared.totalFrameCount
 FramesTracker.shared.slowFrameCount
 FramesTracker.shared.frozenFrameCount

 // measure a specific window:
 let start = CACurrentMediaTime()
 // ... do something ...
 let end = CACurrentMediaTime()

 let delay = FramesTracker.shared.framesDelay(from: start, to: end)
 let rate  = FramesTracker.shared.hitchRate(from: start, to: end)
 */
