import SwiftUI
import BlueTriangle

struct DiagnosticsListView: View {
    @EnvironmentObject private var manager: MetricKitManager

    var body: some View {
        Group {
            if manager.diagnosticPayloads.isEmpty {
                MatricKitEmptyStateView(
                    title: "No Diagnostic Payloads Yet",
                    systemImage: "exclamationmark.triangle",
                    description: "Diagnostics need a sustained pattern on a real device (crash, hang, CPU or disk exception). Try the Triggers section, then check back or tap Load Past Payloads in the Dashboard section."
                )
            } else {
                List {
                    ForEach(manager.diagnosticPayloads) { payload in
                        NavigationLink {
                            PayloadDetailView(title: "Diagnostic Payload", kind: MetricKitReporter.diagnosticKind, payload: payload)
                        } label: {
                            PayloadRow(payload: payload, label: diagnosticLabel(for: payload))
                        }
                    }
                    .onDelete(perform: manager.deleteDiagnosticPayloads)
                }
            }
        }
        .bttTrack("\(Self.self)")
    }

    /// Maps a payload's top-level JSON keys back to their human-readable
    /// diagnostic titles (e.g. "crashDiagnostics" → "Crash"), so each row in
    /// the list is identifiable at a glance instead of just a timestamp.
    private func diagnosticLabel(for payload: StoredPayload) -> String {
        let keys = Set(payload.topLevelObject.keys)
        let titles = FeatureCatalog.diagnosticFeatures.filter { keys.contains($0.key) }.map(\.title)
        return titles.isEmpty ? "Diagnostic" : titles.joined(separator: ", ")
    }
}

#Preview {
    DiagnosticsListView()
        .environmentObject(MetricKitManager.shared)
}
