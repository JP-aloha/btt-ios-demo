import Foundation
import MetricKit
import Combine

/// Central subscriber for Apple's MetricKit framework. Registers itself with
/// MXMetricManager, archives every payload it is handed, and exposes the
/// archive plus manually-loaded system history to the UI.
final class MetricKitManager: NSObject, ObservableObject, MXMetricManagerSubscriber {
    static let shared = MetricKitManager()

    @Published private(set) var metricPayloads: [StoredPayload] = []
    @Published private(set) var diagnosticPayloads: [StoredPayload] = []
    @Published private(set) var lastMetricReceivedAt: Date?
    @Published private(set) var lastDiagnosticReceivedAt: Date?
    @Published private(set) var isSubscribed = false

    /// Every top-level JSON key seen across all archived payloads, used to
    /// drive the "which MetricKit features have we actually observed" checklist.
    var observedFeatureKeys: Set<String> {
        var keys = Set<String>()
        for payload in metricPayloads + diagnosticPayloads {
            for (key, value) in payload.topLevelObject where !(value is NSNull) {
                keys.insert(key)
            }
        }
        return keys
    }

    /// The actual observed JSON value for a feature key, pulled from the most
    /// recent payload that contains it — used to report real MetricKit data
    /// for a Dashboard row instead of just its static catalog description.
    func latestObservedDataSnippet(forKey key: String) -> String? {
        let payloads = (metricPayloads + diagnosticPayloads).sorted { $0.timestampBegin > $1.timestampBegin }
        for payload in payloads {
            guard let value = payload.topLevelObject[key], !(value is NSNull) else { continue }
            if JSONSerialization.isValidJSONObject(value),
               let data = try? JSONSerialization.data(withJSONObject: value) {
                return String(data: data, encoding: .utf8)
            }
            return String(describing: value)
        }
        return nil
    }

    var totalArchiveSize: String {
        let bytes = (metricPayloads + diagnosticPayloads).reduce(0) { $0 + $1.sizeInBytes }
        return ByteCountFormatter.string(fromByteCount: Int64(bytes), countStyle: .file)
        
       // MXAppResponsivenessMetric
    }

    private let archive = PayloadArchive()

    private override init() {
        super.init()
        loadPersistedArchive()
        MXMetricManager.shared.add(self)
        isSubscribed = true
    }

    deinit {
        MXMetricManager.shared.remove(self)
    }

    // MARK: - MXMetricManagerSubscriber

    func didReceive(_ payloads: [MXMetricPayload]) {
        DispatchQueue.main.async {
            for payload in payloads {
                self.insert(self.archive.save(payload: payload), into: \.metricPayloads)
            }
            self.lastMetricReceivedAt = Date()
        }
    }

    func didReceive(_ payloads: [MXDiagnosticPayload]) {
        DispatchQueue.main.async {
            for payload in payloads {
                self.insert(self.archive.save(payload: payload), into: \.diagnosticPayloads)
            }
            self.lastDiagnosticReceivedAt = Date()
        }
    }

    // MARK: - Manual system history

    /// Pulls whatever MXMetricManager already has cached instead of waiting
    /// for the next ~24h automatic delivery window.
    func loadPastPayloadsFromSystem() {
        for payload in MXMetricManager.shared.pastPayloads {
            insert(archive.save(payload: payload), into: \.metricPayloads)
        }
        for payload in MXMetricManager.shared.pastDiagnosticPayloads {
            insert(archive.save(payload: payload), into: \.diagnosticPayloads)
        }
    }

    /// Populates the Metrics/Diagnostics sections with synthetic payloads so the UI
    /// can be previewed immediately, without waiting on a real MetricKit delivery.
    func loadSampleData() {
        let end = Date()
        let begin = end.addingTimeInterval(-24 * 60 * 60)
        let metricJSON = SampleData.metricPayloadJSON(begin: begin, end: end)
        insert(archive.saveSampleMetric(json: metricJSON, begin: begin, end: end), into: \.metricPayloads)

        // Each sample gets its own hour-long window within the day so every
        // diagnostic lands as its own distinct, separately-visible entry.
        for (offset, sample) in SampleData.diagnosticSamples(begin: begin, end: end).enumerated() {
            let sampleBegin = begin.addingTimeInterval(TimeInterval(offset) * 3600)
            let sampleEnd = sampleBegin.addingTimeInterval(3600)
            insert(archive.saveSampleDiagnostic(json: sample.json, begin: sampleBegin, end: sampleEnd), into: \.diagnosticPayloads)
        }
    }

    func clearArchive() {
        archive.clearAll()
        metricPayloads.removeAll()
        diagnosticPayloads.removeAll()
    }

    func deleteMetricPayloads(at offsets: IndexSet) {
        offsets.map { metricPayloads[$0] }.forEach(archive.delete)
        metricPayloads.remove(atOffsets: offsets)
    }

    func deleteDiagnosticPayloads(at offsets: IndexSet) {
        offsets.map { diagnosticPayloads[$0] }.forEach(archive.delete)
        diagnosticPayloads.remove(atOffsets: offsets)
    }

    private func loadPersistedArchive() {
        metricPayloads = archive.loadStoredMetrics()
        diagnosticPayloads = archive.loadStoredDiagnostics()
    }

    private func insert(_ payload: StoredPayload, into keyPath: ReferenceWritableKeyPath<MetricKitManager, [StoredPayload]>) {
        guard !self[keyPath: keyPath].contains(where: { $0.id == payload.id }) else { return }
        self[keyPath: keyPath].append(payload)
        self[keyPath: keyPath].sort { $0.timestampBegin > $1.timestampBegin }
    }
}
