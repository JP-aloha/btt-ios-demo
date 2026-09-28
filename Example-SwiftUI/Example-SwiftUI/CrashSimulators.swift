//
//  CrashSimulators.swift
//  Example-SwiftUI
//
//  One trigger per error type the BlueTriangle SDK reports (the `eTp` of the
//  err.rcv payload), covering the MetricKit tab's triggers as well. Each
//  trigger has a short `tag` that's remembered before it fires, so the
//  resulting payload in User → Error Logs (and its mail attachment's file
//  name) says which trigger produced it.
//

import Foundation
import UIKit

struct CrashType: Identifiable {
    let id: String
    let title: String
    let detail: String
    let systemImage: String
    /// Goes into the Error Logs entry and attachment file name, e.g.
    /// `NativeAppCrash_NSException_<timestamp>.json`.
    let tag: String
    /// Runs the trigger; `status` is called for triggers that don't crash.
    let trigger: (_ status: @escaping (String) -> Void) -> Void
}

struct CrashCategory: Identifiable {
    /// The SDK error type (`eTp`) this section produces.
    let errorType: String
    let footer: String
    let types: [CrashType]

    var id: String { errorType }
}

enum CrashSimulators {

    static let categories: [CrashCategory] = [
        CrashCategory(
            errorType: "NativeAppCrash",
            footer: "Crashes immediately. The SDK uploads the report on the next launch; MetricKit may also deliver its own crash diagnostic later.",
            types: [
                CrashType(id: "swiftCrash", title: "Swift Crash", detail: "fatalError() — same as the MetricKit POC's test crash", systemImage: "exclamationmark.octagon", tag: "SwiftCrash") { _ in
                    StressSimulators.triggerCrash()
                },
                // The rest mirror MatricKitPoc's CrashTypeCatalog, with the same
                // names as tags so payloads line up with the POC's.
                CrashType(id: "nsException", title: "NSException", detail: "Raises an uncaught NSException directly — Objective-C style crash (SIGABRT), distinct from a Swift runtime trap.", systemImage: "bolt.trianglebadge.exclamationmark", tag: "NSException") { _ in
                    NSException(name: NSExceptionName("BTTDemoException"),
                                reason: "BTT Demo: user-triggered NSException test crash.",
                                userInfo: nil).raise()
                },
                CrashType(id: "forceUnwrap", title: "Force Unwrap nil", detail: "Force-unwraps a nil Optional (optional!) — one of the most common real-world Swift crashes.", systemImage: "questionmark.circle", tag: "ForceUnwrapNil") { _ in
                    let value: Int? = runtimeNil()
                    print(value!)
                },
                CrashType(id: "simultaneousAccess", title: "Simultaneous Thread Read/Write", detail: "Overlapping access to the same shared state — Swift's exclusivity enforcement traps with \"Simultaneous accesses...\".", systemImage: "arrow.triangle.2.circlepath", tag: "SimultaneousThreadAccess") { _ in
                    recurseWithExclusiveAccess(&sharedCounter)
                },
                CrashType(id: "divideByZero", title: "Divide by Zero", detail: "Integer division by a runtime-computed zero — traps with \"Fatal error: Division by zero\".", systemImage: "divide", tag: "DivideByZero") { _ in
                    print(100 / runtimeValue(0))
                },
                CrashType(id: "forceCast", title: "Force Cast String to Int", detail: "Force-casts an Any holding a String to Int (as!) — a failed type cast, distinct from a failed optional unwrap.", systemImage: "arrow.triangle.swap", tag: "ForceCastStringToInt") { _ in
                    let value: Any = "not a number"
                    print(value as! Int)
                },
                CrashType(id: "arrayOutOfBounds", title: "Array Index Out of Bounds", detail: "Indexes past the end of an empty array — extremely common in real-world crash reports.", systemImage: "list.number", tag: "ArrayIndexOutOfBounds") { _ in
                    let values: [Int] = []
                    print(values[runtimeValue(5)])
                },
                CrashType(id: "unrecognizedSelector", title: "Unrecognized Selector", detail: "Calls a selector that doesn't exist on an NSObject — classic Objective-C runtime dispatch crash.", systemImage: "cursorarrow.click.badge.clock", tag: "UnrecognizedSelector") { _ in
                    _ = NSObject().perform(NSSelectorFromString("bttDemoDoesNotExist"))
                },
                CrashType(id: "stackOverflow", title: "Stack Overflow", detail: "Infinite recursion exhausts the call stack — EXC_BAD_ACCESS from stack overflow, a different signal than the Swift traps above.", systemImage: "arrow.clockwise", tag: "StackOverflow") { _ in
                    print(recurse(runtimeValue(1)))
                },
                CrashType(id: "invalidMemoryAccess", title: "Invalid Memory Access", detail: "Writes through a raw pointer to an unmapped address — a genuine SIGSEGV, not a Swift runtime trap.", systemImage: "memorychip", tag: "InvalidMemoryAccess") { _ in
                    UnsafeMutablePointer<Int>(bitPattern: runtimeValue(0x10))!.pointee = 42
                },
            ]
        ),
        CrashCategory(
            errorType: "ANRWarning",
            footer: "Reported by the SDK's ANR watchdog within a few seconds, and by MetricKit's hang diagnostic later.",
            types: [
                CrashType(id: "hang", title: "Hang", detail: "Block the main thread for 8 seconds", systemImage: "hourglass", tag: "Hang") { status in
                    StressSimulators.hangMainThread(duration: 8)
                    status("Main thread was blocked for 8s. Check Error Logs for ANRWarning.")
                },
            ]
        ),
        CrashCategory(
            errorType: "MemoryWarning",
            footer: "Reported right away.",
            types: [
                CrashType(id: "memoryWarning", title: "Memory Warning", detail: "Post didReceiveMemoryWarningNotification", systemImage: "exclamationmark.triangle", tag: "MemoryWarning") { status in
                    NotificationCenter.default.post(name: UIApplication.didReceiveMemoryWarningNotification, object: UIApplication.shared)
                    status("Memory warning posted. Check Error Logs for MemoryWarning.")
                },
            ]
        ),
        CrashCategory(
            errorType: "ExcessCPUUsage",
            footer: "MetricKit cpuExceptionDiagnostic — needs iOS to kill the app for CPU use while backgrounded, not attached to Xcode. Delivered on a later launch (can take up to 24h).",
            types: [
                CrashType(id: "cpuException", title: "Excess CPU Use", detail: "Spin the CPU in the background — background the app right after tapping", systemImage: "cpu", tag: "CPUException") { status in
                    status("Running CPU abuse — background the app now and leave it for a minute or two.")
                    StressSimulators.cpuSpinInBackground { elapsed in
                        status("Background CPU abuse ran for \(Int(elapsed))s without being killed. Try again for longer or across sessions.")
                    }
                },
            ]
        ),
        CrashCategory(
            errorType: "HeavyDiskWrite",
            footer: "MetricKit diskWriteExceptionDiagnostic — needs iOS to kill the app for excessive writes while backgrounded. Delivered on a later launch (can take up to 24h).",
            types: [
                CrashType(id: "diskWriteException", title: "Excess Disk Write", detail: "Write 10 MB chunks in the background — background the app right after tapping", systemImage: "internaldrive", tag: "DiskWriteException") { status in
                    status("Running disk abuse — background the app now and leave it for a minute or two.")
                    StressSimulators.diskChurnInBackground { elapsed in
                        status("Background disk abuse ran for \(Int(elapsed))s without being killed. Try again for longer or across sessions.")
                    }
                },
            ]
        ),
        CrashCategory(
            errorType: "SlowLaunch",
            footer: "MetricKit appLaunchDiagnostic (iOS 16+). Uses the last saved Slow Launch settings (default: 18s sleep from willFinishLaunching).",
            types: [
                CrashType(id: "slowLaunch", title: "Slow Launch", detail: "Delay the next cold launch", systemImage: "hare", tag: "SlowLaunch") { status in
                    let delay = StressSimulators.savedSlowLaunchDelay
                    StressSimulators.armSlowLaunch(delay: delay,
                                                   callSite: StressSimulators.savedSlowLaunchCallSite,
                                                   method: StressSimulators.savedSlowLaunchMethod)
                    status("Armed a \(Int(delay))s slow launch. Force-quit the app and relaunch it from the home screen.")
                },
            ]
        ),
        CrashCategory(
            errorType: "ForceRestart",
            footer: "Detected by the SDK when the app is force-quit and reopened within 10 seconds.",
            types: [
                CrashType(id: "forceRestart", title: "Force Restart", detail: "Swipe the app away, then reopen it within 10 seconds", systemImage: "arrow.clockwise.circle", tag: "ForceRestart") { status in
                    status("Now swipe the app away in the app switcher and reopen it within 10 seconds.")
                },
            ]
        ),
    ]

    // Routed through @inline(never) so the compiler can't prove the crash at
    // build time and reject or optimise it away.
    @inline(never)
    private static func runtimeValue(_ value: Int) -> Int { value }

    @inline(never)
    private static func runtimeNil() -> Int? { nil }

    @inline(never)
    private static func recurse(_ depth: Int) -> Int {
        if depth < 0 { return 0 }
        var frame = (depth, depth, depth, depth, depth, depth, depth, depth)
        return withUnsafeMutablePointer(to: &frame) { recurse(depth + 1) + $0.pointee.0 }
    }

    /// Re-enters with `&sharedCounter` while the outer `inout` access to it is
    /// still active, so exclusivity enforcement traps on the first recursion.
    private static var sharedCounter = 0

    @inline(never)
    private static func recurseWithExclusiveAccess(_ value: inout Int) {
        value += 1
        if value > 1_000_000 { return }
        recurseWithExclusiveAccess(&sharedCounter)
    }
}
