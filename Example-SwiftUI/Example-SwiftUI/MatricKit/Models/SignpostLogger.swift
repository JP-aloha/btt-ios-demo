import Foundation
import MetricKit
import os

/// Wraps MXMetricManager.makeLogHandle + mxSignpost to produce a custom
/// MXSignpostMetric entry in the next metric payload.
final class SignpostLogger {
    private let log: OSLog

    init(category: String = "MatricKitPocDemo") {
        log = MXMetricManager.makeLogHandle(category: category)
    }

    func begin() {
        mxSignpost(.begin, log: log, name: "MatricKitPocInterval", signpostID: .exclusive)
    }

    func end() {
        mxSignpost(.end, log: log, name: "MatricKitPocInterval", signpostID: .exclusive)
    }
}
