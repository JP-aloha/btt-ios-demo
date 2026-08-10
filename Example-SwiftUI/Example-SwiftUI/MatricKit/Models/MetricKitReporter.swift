import BlueTriangle
import Foundation

/// Human-readable byte size of a message body, so it's obvious at a glance
/// how large each report being sent to Blue Triangle actually is.
private func formattedMessageSize(_ text: String) -> String {
    ByteCountFormatter.string(fromByteCount: Int64(text.utf8.count), countStyle: .file)
}

private func formattedReportDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
    return formatter.string(from: date)
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

/// Plain-text, sectioned layout — a header line, then labeled sections with
/// one "Key: Value" field per line — matching how Crashlytics/Apple crash
/// reports read (not JSON, not a single delimiter-joined run-on string).
private func industryStyleReport(header: String, sections: [(title: String, fields: [(String, String)])]) -> String {
    var lines: [String] = [header, "Report Time: \(formattedReportDate(Date()))"]
    for section in sections where !section.fields.isEmpty {
        lines.append("")
        lines.append("--- \(section.title) ---")
        for (key, value) in section.fields {
            lines.append("\(key): \(value)")
        }
    }
    return lines.joined(separator: "\n")
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

    /// Above this length, a field's value gets replaced with a short
    /// placeholder instead of dumped in full — real crash call stacks
    /// (crashDiagnostics.callStackTree) recurse through hundreds of nested
    /// subFrames and can run to tens of KB on their own, which is what was
    /// blowing up report size. Device info and most metric fields are well
    /// under this either way, so they're unaffected.
    private static let maxFieldValueLength = 200

    /// Turns a dictionary's keys into "Key: Value" lines, one per field —
    /// each value re-serialized to compact JSON only if it's itself an
    /// object/array (so nested structure stays readable on one line), with
    /// oversized values collapsed to a size placeholder.
    private static func fields(from dict: [String: Any]) -> [(String, String)] {
        dict.keys.sorted().compactMap { key in
            guard let value = dict[key], !(value is NSNull) else { return nil }

            if diagnosticArrayKeys.contains(key), let entries = value as? [[String: Any]] {
                return (key, summarizedDiagnosticEntries(entries))
            }

            let rendered: String
            if JSONSerialization.isValidJSONObject(value),
               let data = try? JSONSerialization.data(withJSONObject: value) {
                rendered = String(data: data, encoding: .utf8) ?? ""
            } else {
                rendered = String(describing: value)
            }
            guard rendered.count > maxFieldValueLength else {
                return (key, rendered)
            }
            let size = ByteCountFormatter.string(fromByteCount: Int64(rendered.utf8.count), countStyle: .file)
            return (key, "<omitted — \(size), too large for this report>")
        }
    }

    /// Metric payloads carry device/OS info under "metaData" at the top
    /// level; crash diagnostics instead carry it under "diagnosticMetaData"
    /// nested inside each crashDiagnostics entry (matching the SDK's own
    /// MetricKitCrashReport.diagnosticMetaData property) — so both key names
    /// are searched for, at any depth, rather than assuming one fixed shape.
    private static let metaDataKeys: Set<String> = ["metaData", "diagnosticMetaData"]

    private static func findMetaData(in value: Any) -> [String: Any]? {
        if let dict = value as? [String: Any] {
            for key in metaDataKeys {
                if let metaData = dict[key] as? [String: Any] {
                    return metaData
                }
            }
            for (_, nested) in dict {
                if let found = findMetaData(in: nested) {
                    return found
                }
            }
        } else if let array = value as? [Any] {
            for element in array {
                if let found = findMetaData(in: element) {
                    return found
                }
            }
        }
        return nil
    }

    private static func extractMetaData(from payloadObject: inout [String: Any]) -> [String: Any]? {
        for key in metaDataKeys {
            if let topLevel = payloadObject.removeValue(forKey: key) as? [String: Any] {
                return topLevel
            }
        }
        return findMetaData(in: payloadObject)
    }

    /// Bound on how many frames to walk down the crashed (or first) thread's
    /// call chain — a real stack trace, but capped so it stays a reasonable
    /// size instead of the full recursive subFrames tree (which can run
    /// hundreds of frames deep and tens of KB on its own).
    private static let maxStackTraceFrames = 25

    /// Each frame line carries everything MetricKit gives us about that
    /// frame, not just binary+address — sample count (how often the
    /// sampler caught this frame, a rough "hotness" signal) and branch
    /// count (how many sibling call paths existed below it, when the tree
    /// forks) turn a bare address list into something closer to a real
    /// symbolicated trace.
    private static func stackTraceSummary(callStackTree: [String: Any]) -> String? {
        guard let callStacks = callStackTree["callStacks"] as? [[String: Any]] else { return nil }
        let stack = callStacks.first(where: { ($0["threadAttributed"] as? Bool) == true }) ?? callStacks.first
        guard let rootFrames = stack?["callStackRootFrames"] as? [[String: Any]], !rootFrames.isEmpty else { return nil }

        // callStackRootFrames is the LEAST recently called frame (e.g. thread
        // entry point) — each subFrames step goes one call deeper, so the
        // leaf at the end of the chain (no more subFrames) is where the
        // thread actually was when sampled/crashed. Walk the whole root-to-leaf
        // chain (capped generously so a pathological tree can't run away),
        // then keep only the tail closest to the leaf/crash frame and reverse
        // it so frame #0 is that innermost frame — matching how every real
        // crash report (Apple, Crashlytics) numbers frames. Capping from the
        // root side instead would keep the least useful (thread-entry) end
        // and silently drop the actual crash location.
        var chain: [[String: Any]] = []
        var frame: [String: Any]? = rootFrames.first
        while let current = frame, chain.count < 500 {
            chain.append(current)
            let subFrames = current["subFrames"] as? [[String: Any]]
            frame = subFrames?.first
        }
        let innermost = chain.suffix(maxStackTraceFrames)

        let lines = innermost.reversed().enumerated().map { index, current -> String in
            let binaryName = current["binaryName"] as? String ?? "Unknown"
            let addressValue = (current["address"] as? NSNumber)?.uint64Value ?? 0
            let offsetValue = (current["offsetIntoBinaryTextSegment"] as? NSNumber)?.uint64Value ?? 0
            let address = String(addressValue, radix: 16, uppercase: true)
            let offset = String(offsetValue, radix: 16, uppercase: true)

            var detail = "#\(index) \(binaryName) 0x\(address) + 0x\(offset)"
            if let sampleCount = current["sampleCount"] as? NSNumber {
                detail += ", samples: \(sampleCount)"
            }
            if let binaryUUID = current["binaryUUID"] as? String {
                detail += ", uuid: \(binaryUUID)"
            }
            if let branchCount = (current["subFrames"] as? [[String: Any]])?.count, branchCount > 1 {
                detail += ", branches: \(branchCount)"
            }
            return detail
        }
        return lines.joined(separator: "\n  ")
    }

    /// crashDiagnostics/hangDiagnostics/etc. entries mix a handful of small,
    /// meaningful scalar fields (exceptionType, signal, terminationReason...)
    /// with a huge recursive callStackTree and their own nested metaData.
    /// Both are pulled out separately — metaData into Device Info, and
    /// callStackTree into a bounded stack trace — so only the remaining
    /// small scalar fields stay inline here.
    private static func summarizedDiagnosticEntries(_ entries: [[String: Any]]) -> String {
        entries.map { entry -> String in
            var parts: [(String, String)] = []
            for key in entry.keys.sorted() where key != "callStackTree" && !metaDataKeys.contains(key) {
                guard let value = entry[key], !(value is NSNull) else { continue }
                parts.append((key, String(describing: value)))
            }
            if let callStackTree = entry["callStackTree"] as? [String: Any],
               let trace = stackTraceSummary(callStackTree: callStackTree) {
                parts.append(("stackTrace", trace))
            }
            return "{ " + parts.map { "\($0.0): \($0.1)" }.joined(separator: ", ") + " }"
        }.joined(separator: "; ")
    }

    /// Diagnostic-type keys whose array entries get the scalar+top-frame
    /// summary above, rather than the generic size-capped rendering.
    private static let diagnosticArrayKeys: Set<String> = [
        "crashDiagnostics", "hangDiagnostics", "cpuExceptionDiagnostics",
        "diskWriteExceptionDiagnostics", "appLaunchDiagnostics"
    ]

    private static func message(for payload: StoredPayload, kind: String) -> String {
        var payloadObject = (try? JSONSerialization.jsonObject(with: payload.jsonData) as? [String: Any]) ?? [:]

        // MetricKit's own "metaData" (device/app/OS info) reads naturally as
        // its own section, same as device info in a real crash report header.
        var deviceFields: [(String, String)] = []
        if let metaData = extractMetaData(from: &payloadObject) {
            deviceFields = fields(from: metaData)
        }

        return industryStyleReport(
            header: "Non-Fatal Error: MatricKit \(kind)",
            sections: [
                ("Device Info", deviceFields),
                ("Data", fields(from: payloadObject))
            ]
        )
    }

    private static func message(feature: FeatureDescriptor, kind: String, isObserved: Bool, dataSnippet: String?) -> String {
        var featureFields: [(String, String)] = [
            ("Number", "\(feature.number)"),
            ("Title", feature.title),
            ("Key", feature.key),
            ("Observed", "\(isObserved)")
        ]
        if let dataSnippet {
            featureFields.append(("Data", dataSnippet))
        } else {
            featureFields.append(("How To Trigger", feature.howToTrigger))
        }
        return industryStyleReport(
            header: "Non-Fatal Error: MatricKit \(kind)",
            sections: [("Feature", featureFields)]
        )
    }

    private static func message(session: HitchRateSession) -> String {
        let begin = session.startDate.formatted(date: .abbreviated, time: .shortened)
        let end = session.endDate.formatted(date: .abbreviated, time: .shortened)
        let resultFields: [(String, String)] = [
            ("Frames", "\(session.frameCount)"),
            ("Hitches", "\(session.hitchCount)"),
            ("Hitch Percentage", String(format: "%.2f%%", session.hitchPercentage)),
            ("Hitch Time Ratio", String(format: "%.2f ms per s", session.hitchTimeRatioMsPerSecond))
        ]
        return industryStyleReport(
            header: "Non-Fatal Error: MatricKit Hitch Rate Session",
            sections: [
                ("Window", [("Begin", begin), ("End", end)]),
                ("Results", resultFields)
            ]
        )
    }

    /// Human-readable size of what would be reported for this payload, for
    /// display in the UI ahead of (or independent of) actually reporting it.
    static func reportedSize(for payload: StoredPayload, kind: String) -> String {
        formattedMessageSize(message(for: payload, kind: kind))
    }

    /// Human-readable size of what would be reported for this Dashboard row.
    static func reportedSize(feature: FeatureDescriptor, kind: String, isObserved: Bool, dataSnippet: String?) -> String {
        formattedMessageSize(message(feature: feature, kind: kind, isObserved: isObserved, dataSnippet: dataSnippet))
    }

    /// Human-readable size of what would be reported for this hitch-rate session.
    static func reportedSize(session: HitchRateSession) -> String {
        formattedMessageSize(message(session: session))
    }

    /// Reports a full archived payload (metric or diagnostic, real or sample).
    static func report(_ payload: StoredPayload, kind: String) {
        let text = message(for: payload, kind: kind)
        print("[MetricKitReporter] Sending to Blue Triangle:\n\(text)")
        BlueTriangle.logError(WrappedReportedError(text: text))
    }

    /// Reports a single Dashboard checklist row (one of the 5 diagnostics or
    /// 14 metrics), including the actual observed data for it when available.
    static func reportFeature(_ feature: FeatureDescriptor, kind: String, isObserved: Bool, dataSnippet: String?) {
        let text = message(feature: feature, kind: kind, isObserved: isObserved, dataSnippet: dataSnippet)
        print("[MetricKitReporter] Sending to Blue Triangle:\n\(text)")
        BlueTriangle.logError(WrappedReportedError(text: text))
    }

    /// Reports a saved hitch-rate session.
    static func report(_ session: HitchRateSession) {
        let text = message(session: session)
        print("[MetricKitReporter] Sending to Blue Triangle:\n\(text)")
        BlueTriangle.logError(WrappedReportedError(text: text))
    }
}
