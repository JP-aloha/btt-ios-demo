import BlueTriangle
import Foundation

/// Human-readable byte size of a message body, so it's obvious at a glance
/// how large each report being sent to Blue Triangle actually is.
private func formattedMessageSize(_ text: String) -> String {
    ByteCountFormatter.string(fromByteCount: Int64(text.utf8.count), countStyle: .file)
}

/// BlueTriangle.logError only accepts a Swift `Error` — whatever is passed
/// gets converted into the uploaded report's message. Conforming to
/// `LocalizedError` (not just `CustomStringConvertible`) matters here: when a
/// Swift error crosses into Foundation's NSError bridging, only
/// `LocalizedError.errorDescription` is consulted for `localizedDescription` —
/// a plain `CustomStringConvertible.description` is silently ignored there,
/// which is what previously produced the generic "The operation couldn't be
/// completed. (...MetricKitReportedError error 1.)" message instead of ours.
private struct WrappedReportedError: Error, LocalizedError, CustomStringConvertible {
    let text: String
    var description: String { text }
    var errorDescription: String? { text }
}

/// Manually forwards MetricKit data to Blue Triangle via BlueTriangle.logError,
/// so it shows up in Blue Triangle's own crash/error reporting rather than
/// only locally here. Message-building is exposed separately from the actual
/// report call so the UI can preview the same size before/without reporting.
enum MetricKitReporter {
    /// Diagnostics represent actual app-health problems, so they're labeled
    /// as errors; metrics are just routine measurements.
    static let diagnosticKind = "Error (Diagnostic)"
    static let metricKind = "Metric"

    /// Splits the message into its title tag and the remaining detail, so the
    /// size annotation can be inserted right after the title instead of at
    /// the very front or the very end.
    private static func baseMessage(for payload: StoredPayload, kind: String) -> (title: String, rest: String) {
        let json = String(data: payload.jsonData, encoding: .utf8) ?? "{}"
        let begin = payload.timestampBegin.formatted(date: .abbreviated, time: .shortened)
        let end = payload.timestampEnd.formatted(date: .abbreviated, time: .shortened)
        return ("[MatricKit \(kind) Payload]", "\(begin) – \(end): \(json)")
    }

    private static func baseMessage(feature: FeatureDescriptor, kind: String, isObserved: Bool, dataSnippet: String?) -> (title: String, rest: String) {
        var rest = "(key: \(feature.key)) — observed: \(isObserved)."
        if let dataSnippet {
            rest += " Data: \(dataSnippet)"
        } else {
            rest += " How to trigger: \(feature.howToTrigger)"
        }
        return ("[MatricKit \(kind)] #\(feature.number) \(feature.title)", rest)
    }

    private static func baseMessage(session: HitchRateSession) -> (title: String, rest: String) {
        let begin = session.startDate.formatted(date: .abbreviated, time: .shortened)
        let end = session.endDate.formatted(date: .abbreviated, time: .shortened)
        let rest = "\(begin) – \(end): frames=\(session.frameCount), hitches=\(session.hitchCount), " +
            "hitchPercentage=\(String(format: "%.2f", session.hitchPercentage))%, " +
            "hitchTimeRatio=\(String(format: "%.2f", session.hitchTimeRatioMsPerSecond)) ms per s"
        return ("[MatricKit Hitch Rate Session]", rest)
    }

    private static func compose(title: String, rest: String) -> (full: String, size: String) {
        let full = "\(title) \(rest)"
        return (full, formattedMessageSize(full))
    }

    /// Human-readable size of what would be reported for this payload, for
    /// display in the UI ahead of (or independent of) actually reporting it.
    static func reportedSize(for payload: StoredPayload, kind: String) -> String {
        let (title, rest) = baseMessage(for: payload, kind: kind)
        return compose(title: title, rest: rest).size
    }

    /// Human-readable size of what would be reported for this Dashboard row.
    static func reportedSize(feature: FeatureDescriptor, kind: String, isObserved: Bool, dataSnippet: String?) -> String {
        let (title, rest) = baseMessage(feature: feature, kind: kind, isObserved: isObserved, dataSnippet: dataSnippet)
        return compose(title: title, rest: rest).size
    }

    /// Human-readable size of what would be reported for this hitch-rate session.
    static func reportedSize(session: HitchRateSession) -> String {
        let (title, rest) = baseMessage(session: session)
        return compose(title: title, rest: rest).size
    }

    /// Reports a full archived payload (metric or diagnostic, real or sample).
    static func report(_ payload: StoredPayload, kind: String) {
        let (title, rest) = baseMessage(for: payload, kind: kind)
        let size = compose(title: title, rest: rest).size
        BlueTriangle.logError(WrappedReportedError(text: "\(title) (Size: \(size)) \(rest)"))
    }

    /// Reports a single Dashboard checklist row (one of the 5 diagnostics or
    /// 14 metrics), including the actual observed data for it when available.
    static func reportFeature(_ feature: FeatureDescriptor, kind: String, isObserved: Bool, dataSnippet: String?) {
        let (title, rest) = baseMessage(feature: feature, kind: kind, isObserved: isObserved, dataSnippet: dataSnippet)
        let size = compose(title: title, rest: rest).size
        BlueTriangle.logError(WrappedReportedError(text: "\(title) (Size: \(size)) \(rest)"))
    }

    /// Reports a saved hitch-rate session.
    static func report(_ session: HitchRateSession) {
        let (title, rest) = baseMessage(session: session)
        let size = compose(title: title, rest: rest).size
        BlueTriangle.logError(WrappedReportedError(text: "\(title) (Size: \(size)) \(rest)"))
    }

}
