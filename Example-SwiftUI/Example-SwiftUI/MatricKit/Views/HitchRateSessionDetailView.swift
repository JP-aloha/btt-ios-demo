import SwiftUI
import BlueTriangle

struct HitchRateSessionDetailView: View {
    let session: HitchRateSession
    @State private var showReportedConfirmation = false

    var body: some View {
        List {
            Section("Window") {
                LabeledContent("Started", value: session.startDate.formatted())
                LabeledContent("Ended", value: session.endDate.formatted())
                LabeledContent("Duration", value: String(format: "%.1f s", session.duration))
            }

            Section("Results") {
                LabeledContent("Frames observed", value: "\(session.frameCount)")
                LabeledContent("Hitches detected", value: "\(session.hitchCount)")
                LabeledContent("Hitch percentage", value: String(format: "%.2f%%", session.hitchPercentage))
                LabeledContent("Hitch time ratio", value: String(format: "%.2f ms per s", session.hitchTimeRatioMsPerSecond))
            }

            Section {
                LabeledContent("Report Message Size", value: MetricKitReporter.reportedSize(session: session))
                Button("Report to Blue Triangle") {
                    MetricKitReporter.report(session)
                    showReportedConfirmation = true
                }
            } footer: {
                Text("Sends this session's stats to Blue Triangle via BlueTriangle.logError.")
            }
        }
        .navigationTitle("Hitch Rate Session")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Reported", isPresented: $showReportedConfirmation) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("This hitch-rate session was sent to Blue Triangle via logError.")
        }
        .bttTrack("\(Self.self)")
    }
}

#Preview {
    NavigationStack {
        HitchRateSessionDetailView(session: HitchRateSession(
            id: UUID(),
            startDate: Date().addingTimeInterval(-60),
            endDate: Date(),
            frameCount: 3600,
            hitchCount: 12,
            hitchTimeRatioMsPerSecond: 4.2
        ))
    }
}
