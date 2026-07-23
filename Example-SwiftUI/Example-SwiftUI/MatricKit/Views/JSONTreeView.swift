import SwiftUI
import BlueTriangle

/// Recursively renders a JSONSerialization object graph as an expandable tree,
/// so any field MetricKit reports — including ones not explicitly modeled
/// elsewhere in this app — is still inspectable.
struct JSONTreeView: View {
    let value: Any

    var body: some View {
        if let dictionary = value as? [String: Any] {
            ForEach(dictionary.keys.sorted(), id: \.self) { key in
                DisclosureGroup(key) {
                    JSONTreeView(value: dictionary[key] ?? NSNull())
                }
            }
            .bttTrack("\(Self.self)")
        } else if let array = value as? [Any] {
            if array.isEmpty {
                Text("[] (empty)").foregroundStyle(.secondary)
        .bttTrack("\(Self.self)")
            } else {
                ForEach(Array(array.enumerated()), id: \.offset) { index, item in
                    DisclosureGroup("[\(index)]") {
                        JSONTreeView(value: item)
                    }
                }
                .bttTrack("\(Self.self)")
            }
        } else if value is NSNull {
            Text("null").foregroundStyle(.secondary)
        .bttTrack("\(Self.self)")
        } else {
            Text(String(describing: value))
                .font(.system(.footnote, design: .monospaced))
                .textSelection(.enabled)
                .bttTrack("\(Self.self)")
        }
    }
}
