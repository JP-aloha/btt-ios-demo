import Foundation

/// A locally-archived copy of an `MXMetricPayload` or `MXDiagnosticPayload`,
/// kept as raw JSON so every field MetricKit ever adds is preserved without
/// needing typed decoding for each metric/diagnostic category.
struct StoredPayload: Identifiable, Hashable {
    let id: String
    let timestampBegin: Date
    let timestampEnd: Date
    let jsonData: Data
    let fileURL: URL?

    var prettyJSON: String {
        PrettyJSON.string(from: jsonData)
    }

    var topLevelObject: [String: Any] {
        (try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any]) ?? [:]
    }

    var sizeInBytes: Int { jsonData.count }

    var formattedSize: String {
        ByteCountFormatter.string(fromByteCount: Int64(sizeInBytes), countStyle: .file)
    }

    static func == (lhs: StoredPayload, rhs: StoredPayload) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
