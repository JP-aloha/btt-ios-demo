import SwiftUI

struct PayloadDetailView: View {
    let title: String
    let kind: String
    let payload: StoredPayload
    @State private var showReportedConfirmation = false

    private var topLevelObject: [String: Any] { payload.topLevelObject }
    private var topLevelKeys: [String] { topLevelObject.keys.sorted() }

    var body: some View {
        List {
            Section("Window") {
                LabeledContent("Begin", value: payload.timestampBegin.formatted())
                LabeledContent("End", value: payload.timestampEnd.formatted())
                LabeledContent("Payload Size", value: payload.formattedSize)
            }

            Section("Present Fields (\(topLevelKeys.count))") {
                ForEach(topLevelKeys, id: \.self) { key in
                    DisclosureGroup(key) {
                        JSONTreeView(value: topLevelObject[key] ?? NSNull())
                    }
                }
            }

            Section {
                NavigationLink("View Raw JSON") {
                    RawJSONView(payload: payload)
                }
            }

            Section {
                LabeledContent("Report Message Size", value: MetricKitReporter.reportedSize(for: payload, kind: kind))
                Button("Report to Blue Triangle") {
                    MetricKitReporter.report(payload, kind: kind)
                    showReportedConfirmation = true
                }
            } footer: {
                Text("Sends this payload's JSON to Blue Triangle via BlueTriangle.logError.")
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .alert("Reported", isPresented: $showReportedConfirmation) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("This payload was sent to Blue Triangle via logError.")
        }
    }
}
