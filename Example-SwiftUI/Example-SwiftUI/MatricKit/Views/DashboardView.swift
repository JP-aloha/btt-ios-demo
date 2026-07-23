import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var manager: MetricKitManager
    @State private var showLoadSampleConfirmation = false
    @State private var showClearArchiveConfirmation = false

    var body: some View {
        List {
            Section("Subscriber Status") {
                LabeledContent("MXMetricManagerSubscriber", value: manager.isSubscribed ? "Active" : "Inactive")
                LabeledContent("Metric payloads archived", value: "\(manager.metricPayloads.count)")
                LabeledContent("Diagnostic payloads archived", value: "\(manager.diagnosticPayloads.count)")
                LabeledContent("Total archive size", value: manager.totalArchiveSize)
                if let date = manager.lastMetricReceivedAt {
                    LabeledContent("Last metric delivery", value: date.formatted())
                }
                if let date = manager.lastDiagnosticReceivedAt {
                    LabeledContent("Last diagnostic delivery", value: date.formatted())
                }
            }

            Section {
                Button("Load Past Payloads From System") {
                    manager.loadPastPayloadsFromSystem()
                }
                Button("Load Sample Data (Preview UI)") {
                    showLoadSampleConfirmation = true
                }
                Button("Clear Local Archive", role: .destructive) {
                    showClearArchiveConfirmation = true
                }
            } footer: {
                Text("iOS delivers real MetricKit payloads roughly once every 24 hours, mostly on physical devices — a fresh install has nothing yet. \"Load Past Payloads\" pulls whatever MXMetricManager already cached; \"Load Sample Data\" injects synthetic (fake) payloads so you can preview the Metrics/Diagnostics screens right now.")
            }

            Section {
                Label("Please send feature data to Blue Triangle using the paperplane icon on each row below.", systemImage: "paperplane.circle.fill")
                    .font(.subheadline.bold())
                    .foregroundStyle(.blue)
            }

            Section {
                ForEach(FeatureCatalog.diagnosticFeatures) { feature in
                    FeatureRow(feature: feature, kind: MetricKitReporter.diagnosticKind, isObserved: manager.observedFeatureKeys.contains(feature.key))
                }
            } header: {
                Text("5 Errors (Diagnostics)")
            } footer: {
                Text("Tap a row to see how to exercise that feature. A checkmark means it has appeared in at least one archived payload.")
            }

            Section("14 Metrics") {
                ForEach(FeatureCatalog.metricFeatures) { feature in
                    FeatureRow(feature: feature, kind: MetricKitReporter.metricKind, isObserved: manager.observedFeatureKeys.contains(feature.key))
                }
            }

            Section {
                LabeledContent("Cold launches tracked", value: "\(LaunchHistory.launchCount)")
                if let firstLaunch = LaunchHistory.firstLaunchDate {
                    LabeledContent("Undisturbed since", value: firstLaunch.formatted())
                }
            } header: {
                Text("Launch History")
            } footer: {
                Text("MXAppLaunchDiagnostic flags a launch as \"slow\" relative to this device's own history for the app. Reinstalling (including a fresh Xcode install over the old build) resets this back to zero — for the best chance at a real diagnostic, avoid reinstalling for several days after arming a slow launch.")
            }
        }
        .alert("Load Sample Data?", isPresented: $showLoadSampleConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Load Sample Data") {
                manager.loadSampleData()
            }
        } message: {
            Text("This adds one synthetic (fake) metric payload and one synthetic diagnostic payload to your local archive, purely to preview the Metrics/Diagnostics screens. It is not real MetricKit data.")
        }
        .alert("Clear Local Archive?", isPresented: $showClearArchiveConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Clear Archive", role: .destructive) {
                manager.clearArchive()
            }
        } message: {
            Text("This permanently deletes all \(manager.metricPayloads.count + manager.diagnosticPayloads.count) archived payload(s) from local storage. This cannot be undone.")
        }
    }
}

private struct FeatureRow: View {
    let feature: FeatureDescriptor
    let kind: String
    let isObserved: Bool
    @EnvironmentObject private var manager: MetricKitManager
    @State private var showTip = false
    @State private var showReportedConfirmation = false

    var body: some View {
        HStack {
            Button {
                showTip = true
            } label: {
                HStack {
                    Image(systemName: isObserved ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(isObserved ? .green : .secondary)
                    Text("\(feature.number).")
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                    Text(feature.title)
                        .foregroundStyle(.primary)
                    Image(systemName: "info.circle")
                        .foregroundStyle(.secondary)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Spacer()

            Button {
                let snippet = manager.latestObservedDataSnippet(forKey: feature.key)
                MetricKitReporter.reportFeature(feature, kind: kind, isObserved: isObserved, dataSnippet: snippet)
                showReportedConfirmation = true
            } label: {
                Image(systemName: "paperplane.circle")
                    .foregroundStyle(isObserved ? .blue : .secondary)
            }
            .buttonStyle(.plain)
            .contentShape(Rectangle())
            .disabled(!isObserved)
        }
        .alert(feature.title, isPresented: $showTip) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(feature.howToTrigger)
        }
        .alert("Reported", isPresented: $showReportedConfirmation) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("\"\(feature.title)\" was sent to Blue Triangle Errors Explorer for siteId: \(Secrets.siteID)")
        }
    }
}

#Preview {
    DashboardView()
        .environmentObject(MetricKitManager.shared)
}
