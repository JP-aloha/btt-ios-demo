//
//  CrashSimulators.swift
//  Example-SwiftUI
//
//  One entry per crash / error type the BlueTriangle SDK can report, so each
//  can be reproduced on demand from User → Generate Crash. Each entry
//  terminates the app — the SDK uploads the report (err.rcv) on the next
//  launch, where it shows up in User → Error Logs.
//

import Foundation
import UIKit

struct CrashType: Identifiable {
    let id: String
    let title: String
    let detail: String
    let systemImage: String
    let trigger: () -> Void
}

struct CrashCategory: Identifiable {
    let id: String
    let title: String
    let footer: String
    let types: [CrashType]
}

enum CrashSimulators {

    static let categories: [CrashCategory] = [
        CrashCategory(
            id: "swift",
            title: "Swift Runtime Traps",
            footer: "EXC_BREAKPOINT / SIGTRAP — reported by the signal crash handler and MetricKit crash diagnostics.",
            types: [
                CrashType(id: "fatalError", title: "fatalError()", detail: "Explicit fatalError — same as the MetricKit POC test crash", systemImage: "exclamationmark.octagon") {
                    fatalError("BTT Demo: user-triggered fatalError crash.")
                },
                CrashType(id: "forceUnwrap", title: "Force Unwrap nil", detail: "Unexpectedly found nil while unwrapping an Optional", systemImage: "questionmark.circle") {
                    let value: Int? = runtimeNil()
                    print(value!)
                },
                CrashType(id: "indexOutOfRange", title: "Array Index Out of Range", detail: "Swift Array subscript past its bounds", systemImage: "list.number") {
                    let list = [1, 2]
                    print(list[runtimeValue(10)])
                },
                CrashType(id: "forceCast", title: "Force Cast Failure", detail: "as! to an incompatible type", systemImage: "arrow.triangle.swap") {
                    let any: Any = "BTT" as Any
                    print(any as! Int)
                },
                CrashType(id: "intOverflow", title: "Integer Overflow", detail: "Arithmetic overflow on Int.max + 1", systemImage: "plus.forwardslash.minus") {
                    print(runtimeValue(Int.max) + 1)
                },
                CrashType(id: "divideByZero", title: "Division by Zero", detail: "Integer division by zero", systemImage: "divide") {
                    print(10 / runtimeValue(0))
                },
                CrashType(id: "precondition", title: "preconditionFailure()", detail: "Failed precondition check", systemImage: "checkmark.shield") {
                    preconditionFailure("BTT Demo: user-triggered precondition failure.")
                },
                CrashType(id: "unowned", title: "Unowned Reference Deallocated", detail: "Reading an unowned reference after its object is freed", systemImage: "link.badge.plus") {
                    unownedAccessCrash()
                },
                CrashType(id: "backgroundThread", title: "Background Thread Crash", detail: "fatalError on a background queue", systemImage: "square.stack.3d.down.right") {
                    DispatchQueue.global(qos: .userInitiated).async {
                        fatalError("BTT Demo: crash on background thread.")
                    }
                },
            ]
        ),
        CrashCategory(
            id: "nsexception",
            title: "Objective-C Exceptions",
            footer: "Uncaught NSException / SIGABRT — reported by the SDK's NSException handler (crashTracking = .nsException).",
            types: [
                CrashType(id: "customException", title: "Custom NSException", detail: "NSException(name: BTTTestException).raise()", systemImage: "bolt.trianglebadge.exclamationmark") {
                    NSException(name: NSExceptionName("BTTTestException"),
                                reason: "BTT Demo: user-triggered custom NSException.",
                                userInfo: ["source": "CrashTypesView"]).raise()
                },
                CrashType(id: "nsRange", title: "NSRangeException", detail: "NSArray objectAtIndex: beyond bounds", systemImage: "square.grid.3x1.below.line.grid.1x2") {
                    print(NSArray().object(at: 1))
                },
                CrashType(id: "unrecognizedSelector", title: "Unrecognized Selector", detail: "NSInvalidArgumentException — message sent to an object that doesn't respond", systemImage: "cursorarrow.click.badge.clock") {
                    _ = NSObject().perform(NSSelectorFromString("bttUndefinedSelector"))
                },
                CrashType(id: "unknownKey", title: "NSUnknownKeyException", detail: "KVC value(forKey:) with an undefined key", systemImage: "key") {
                    print(NSObject().value(forKey: "bttUndefinedKey") as Any)
                },
                CrashType(id: "backgroundException", title: "NSException on Background Thread", detail: "NSRangeException raised off the main thread", systemImage: "square.stack.3d.down.right.fill") {
                    DispatchQueue.global(qos: .userInitiated).async {
                        print(NSArray().object(at: 5))
                    }
                },
            ]
        ),
        CrashCategory(
            id: "signals",
            title: "Signals & Memory Errors",
            footer: "Unix signals — reported by the SDK's signal crash handler (BTSignalCrashReporter). SIGKILL can't be caught in-process; only MetricKit sees it.",
            types: [
                CrashType(id: "badAccess", title: "EXC_BAD_ACCESS (SIGSEGV)", detail: "Write through an invalid pointer", systemImage: "memorychip") {
                    UnsafeMutablePointer<Int>(bitPattern: runtimeValue(0x10))!.pointee = 42
                },
                CrashType(id: "abort", title: "abort() (SIGABRT)", detail: "Process abort", systemImage: "xmark.octagon") {
                    abort()
                },
                CrashType(id: "doubleFree", title: "Double Free (SIGABRT)", detail: "Heap corruption — freeing the same pointer twice", systemImage: "trash.slash") {
                    let pointer = UnsafeMutableRawPointer.allocate(byteCount: 64, alignment: 8)
                    pointer.deallocate()
                    pointer.deallocate()
                },
                CrashType(id: "stackOverflow", title: "Stack Overflow", detail: "Unbounded recursion exhausts the stack (EXC_BAD_ACCESS)", systemImage: "arrow.clockwise") {
                    print(recurse(runtimeValue(1)))
                },
                CrashType(id: "mainSyncDeadlock", title: "Main Queue Deadlock", detail: "DispatchQueue.main.sync called from the main thread", systemImage: "lock.rotation") {
                    DispatchQueue.main.sync { print("unreachable") }
                },
                CrashType(id: "sigbus", title: "SIGBUS", detail: "raise(SIGBUS)", systemImage: "bolt") { raise(SIGBUS) },
                CrashType(id: "sigill", title: "SIGILL", detail: "raise(SIGILL) — illegal instruction", systemImage: "bolt") { raise(SIGILL) },
                CrashType(id: "sigfpe", title: "SIGFPE", detail: "raise(SIGFPE) — floating point exception", systemImage: "bolt") { raise(SIGFPE) },
                CrashType(id: "sigtrap", title: "SIGTRAP", detail: "raise(SIGTRAP) — trace/breakpoint trap", systemImage: "bolt") { raise(SIGTRAP) },
                CrashType(id: "sigpipe", title: "SIGPIPE", detail: "raise(SIGPIPE) — broken pipe", systemImage: "bolt") { raise(SIGPIPE) },
                CrashType(id: "sigkill", title: "SIGKILL", detail: "raise(SIGKILL) — uncatchable kill", systemImage: "bolt.slash") { raise(SIGKILL) },
            ]
        ),
    ]

    // MARK: - Helpers

    // Values routed through @inline(never) so the compiler can't prove the
    // crash at build time and reject or optimise it away.
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

    private final class Node {}

    @inline(never)
    private static func unownedAccessCrash() {
        var strong: Node? = Node()
        unowned let weakRef = strong!
        strong = nil
        print(weakRef)
    }
}
