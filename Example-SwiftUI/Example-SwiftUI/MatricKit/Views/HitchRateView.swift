import SwiftUI

struct HitchRateView: View {
    @EnvironmentObject private var monitor: HitchRateMonitor
    @State private var showClearConfirmation = false

    var body: some View {
        Form {
            Section("Saved Sessions") {
                if monitor.sessions.isEmpty {
                    Text("No saved sessions yet. Stop monitoring below to save one.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(monitor.sessions) { session in
                        NavigationLink {
                            HitchRateSessionDetailView(session: session)
                        } label: {
                            HitchRateSessionRow(session: session)
                        }
                    }
                    .onDelete(perform: monitor.deleteSessions)
                    Button("Clear Saved Sessions", role: .destructive) {
                        showClearConfirmation = true
                    }
                }
            }

            Section {
                LabeledContent("Monitoring", value: monitor.isMonitoring ? "Active" : "Stopped")
                LabeledContent("Frames observed", value: "\(monitor.frameCount)")
                LabeledContent("Hitches detected", value: "\(monitor.hitchCount)")
                LabeledContent("Hitch time ratio", value: String(format: "%.2f ms per s", monitor.hitchTimeRatioMsPerSecond))

                Button(monitor.isMonitoring ? "Stop & Save Session" : "Start Monitoring") {
                    if monitor.isMonitoring {
                        monitor.stopAndSaveSession()
                    } else {
                        monitor.start()
                    }
                }
            } header: {
                Text("Live Hitch Rate (animationMetrics)")
            } footer: {
                Text("Uses CADisplayLink to measure real per-frame timing, independent of MetricKit's own animationMetrics.hitchTimeRatio (which only reports a delayed daily aggregate). Stats above only update when you stop — monitoring itself keeps running even if you switch to another section.")
            }

            Section("Simulate a Hitch") {
                Button("Simulate Hitch (0.3s)") {
                    StressSimulators.hangMainThread(duration: 0.3)
                }
                .disabled(!monitor.isMonitoring)
            }

            Section("Scroll to Generate Real Hitches") {
                ForEach(0..<200, id: \.self) { index in
                    Text("Row \(index)")
                }
            }
        }
        .alert("Clear Saved Sessions?", isPresented: $showClearConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Clear", role: .destructive) {
                monitor.clearSessions()
            }
        } message: {
            Text("This permanently deletes all \(monitor.sessions.count) saved hitch-rate session(s). This cannot be undone.")
        }
    }
}

private struct HitchRateSessionRow: View {
    let session: HitchRateSession

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(session.startDate.formatted(date: .abbreviated, time: .shortened))
                    .font(.headline)
                Spacer()
                Text(String(format: "%.2f ms/s", session.hitchTimeRatioMsPerSecond))
                    .font(.caption)
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }
            Text("\(session.frameCount) frames · \(session.hitchCount) hitches · \(String(format: "%.2f%%", session.hitchPercentage)) · \(String(format: "%.1f", session.duration))s")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    HitchRateView()
        .environmentObject(HitchRateMonitor.shared)
}
