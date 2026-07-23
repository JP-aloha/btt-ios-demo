import Foundation
import MetricKit

/// Persists every metric/diagnostic payload the app ever sees to the Documents
/// directory, since MXMetricManager only caches a handful of recent payloads
/// itself and clears them once read.
final class PayloadArchive {
    private let fileManager = FileManager.default

    private lazy var rootURL: URL = {
        let docs = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let root = docs.appendingPathComponent("MetricKitArchive", isDirectory: true)
        try? fileManager.createDirectory(at: root, withIntermediateDirectories: true)
        return root
    }()

    private var metricsDir: URL { subdirectory("Metrics") }
    private var diagnosticsDir: URL { subdirectory("Diagnostics") }

    private func subdirectory(_ name: String) -> URL {
        let url = rootURL.appendingPathComponent(name, isDirectory: true)
        try? fileManager.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    @discardableResult
    func save(payload: MXMetricPayload) -> StoredPayload {
        write(data: payload.jsonRepresentation(), begin: payload.timeStampBegin, end: payload.timeStampEnd, in: metricsDir)
    }

    @discardableResult
    func save(payload: MXDiagnosticPayload) -> StoredPayload {
        write(data: payload.jsonRepresentation(), begin: payload.timeStampBegin, end: payload.timeStampEnd, in: diagnosticsDir)
    }

    /// For demo/sample data only — MXMetricPayload/MXDiagnosticPayload can't be constructed
    /// manually, so synthetic JSON is written directly through the same path real payloads use.
    @discardableResult
    func saveSampleMetric(json: Data, begin: Date, end: Date) -> StoredPayload {
        write(data: json, begin: begin, end: end, in: metricsDir)
    }

    @discardableResult
    func saveSampleDiagnostic(json: Data, begin: Date, end: Date) -> StoredPayload {
        write(data: json, begin: begin, end: end, in: diagnosticsDir)
    }

    private func write(data: Data, begin: Date, end: Date, in directory: URL) -> StoredPayload {
        let id = "\(Int(begin.timeIntervalSince1970))-\(Int(end.timeIntervalSince1970))"
        let fileURL = directory.appendingPathComponent("\(id).json")
        if !fileManager.fileExists(atPath: fileURL.path) {
            try? data.write(to: fileURL, options: .atomic)
        }
        return StoredPayload(id: id, timestampBegin: begin, timestampEnd: end, jsonData: data, fileURL: fileURL)
    }

    func loadStoredMetrics() -> [StoredPayload] {
        loadAll(from: metricsDir)
    }

    func loadStoredDiagnostics() -> [StoredPayload] {
        loadAll(from: diagnosticsDir)
    }

    private func loadAll(from directory: URL) -> [StoredPayload] {
        guard let files = try? fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil) else {
            return []
        }
        return files.compactMap { url -> StoredPayload? in
            guard let data = try? Data(contentsOf: url) else { return nil }
            let id = url.deletingPathExtension().lastPathComponent
            let parts = id.split(separator: "-")
            guard parts.count == 2, let beginSeconds = Double(parts[0]), let endSeconds = Double(parts[1]) else {
                return nil
            }
            return StoredPayload(
                id: id,
                timestampBegin: Date(timeIntervalSince1970: beginSeconds),
                timestampEnd: Date(timeIntervalSince1970: endSeconds),
                jsonData: data,
                fileURL: url
            )
        }.sorted { $0.timestampBegin > $1.timestampBegin }
    }

    func clearAll() {
        try? fileManager.removeItem(at: metricsDir)
        try? fileManager.removeItem(at: diagnosticsDir)
    }

    func delete(_ payload: StoredPayload) {
        guard let fileURL = payload.fileURL else { return }
        try? fileManager.removeItem(at: fileURL)
    }
}
