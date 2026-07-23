import SwiftUI

struct MetricsListView: View {
    @EnvironmentObject private var manager: MetricKitManager

    var body: some View {
        Group {
            if manager.metricPayloads.isEmpty {
                MatricKitEmptyStateView(
                    title: "No Metric Payloads Yet",
                    systemImage: "chart.bar.xaxis",
                    description: "Trigger some activity in the Triggers section, wait for a system delivery, or tap Load Past Payloads in the Dashboard section."
                )
            } else {
                List {
                    ForEach(manager.metricPayloads) { payload in
                        NavigationLink {
                            PayloadDetailView(title: "Metric Payload", kind: MetricKitReporter.metricKind, payload: payload)
                        } label: {
                            PayloadRow(payload: payload)
                        }
                    }
                    .onDelete(perform: manager.deleteMetricPayloads)
                }
            }
        }
    }
}

#Preview {
    MetricsListView()
        .environmentObject(MetricKitManager.shared)
}
