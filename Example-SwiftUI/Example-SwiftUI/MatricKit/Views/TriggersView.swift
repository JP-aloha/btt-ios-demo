import SwiftUI
import BlueTriangle

struct TriggersView: View {
    @State private var cpuDuration: Double = 60
    @State private var hangDuration: Double = 8
    @State private var diskDuration: Double = 30
    @State private var slowLaunchDelay: Double = 18
    @State private var isSpinningCPU = false
    @State private var isChurningDisk = false
    @State private var isAbusingCPUInBackground = false
    @State private var isAbusingDiskInBackground = false
    @State private var isTransferringNetwork = false
    @State private var showForeverHangConfirmation = false
    @State private var signpostActive = false
    @State private var showCrashConfirmation = false
    @State private var statusMessage: String?

    private let signposts = SignpostLogger()

    var body: some View {
        Form {
            Section {
                Label("Diagnostics (all except Crash) are suppressed while Xcode's debugger is attached. After installing, tap Stop in Xcode, then relaunch by tapping the app icon on the device itself — never via Xcode's Run button — before testing any trigger below.", systemImage: "exclamationmark.triangle")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }

            Section("1. Crash (crashDiagnostics)") {
                Button(role: .destructive) {
                    showCrashConfirmation = true
                } label: {
                    Label("Trigger Test Crash", systemImage: "exclamationmark.triangle.fill")
                }
            }

            Section("2. Excess CPU Use (cpuMetrics / cpuExceptionDiagnostics)") {
                Slider(value: $cpuDuration, in: 10...120, step: 10) {
                    Text("Duration")
                }
                Text("Pin all cores near 100% for \(Int(cpuDuration))s. Real diagnostics need sustained load — try 60s+, and repeat across a couple of separate sessions.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Button {
                    isSpinningCPU = true
                    StressSimulators.cpuSpin(duration: cpuDuration) {
                        isSpinningCPU = false
                        statusMessage = "CPU spike complete (\(Int(cpuDuration))s across all cores)."
                    }
                } label: {
                    Label(isSpinningCPU ? "Spinning CPU…" : "Simulate CPU Spike", systemImage: "cpu")
                }
                .disabled(isSpinningCPU)

                Text("cpuExceptionDiagnostics specifically needs the OS to kill the app for CPU abuse *while backgrounded* — the button above (foreground only) can't produce it. Tap below, then immediately background the app (swipe up or press Home) and leave it for a minute or two.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Button {
                    isAbusingCPUInBackground = true
                    StressSimulators.cpuSpinInBackground { elapsed in
                        isAbusingCPUInBackground = false
                        statusMessage = "Background CPU abuse ran for \(Int(elapsed))s without being killed. If the app instead relaunched fresh when you reopened it, that's a stronger sign — check Diagnostics after the next batch window."
                    }
                } label: {
                    Label(isAbusingCPUInBackground ? "Running…" : "Abuse CPU in Background", systemImage: "cpu.fill")
                }
                .disabled(isAbusingCPUInBackground)
            }

            Section("3. Slow Launch (appLaunchDiagnostics, iOS 16+)") {
                Slider(value: $slowLaunchDelay, in: 15...25, step: 1) {
                    Text("Delay")
                }
                Text("Next cold launch will be delayed by \(Int(slowLaunchDelay))s. Real data shows launches up to ~16s only register as \"slow,\" not \"extended\" — stay in this range to test closer to that boundary without risking a launch-watchdog kill.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Button {
                    StressSimulators.armSlowLaunch(delay: slowLaunchDelay)
                    statusMessage = "Armed. Force-quit the app now (swipe up in the app switcher) and relaunch by tapping the icon — the next cold launch will be slowed by \(Int(slowLaunchDelay))s."
                } label: {
                    Label("Arm Slow Launch for Next Cold Launch", systemImage: "hare")
                }
            }

            Section("4. Hang / App Responsiveness (applicationResponsivenessMetrics / hangDiagnostics)") {
                Slider(value: $hangDuration, in: 3...30, step: 1) {
                    Text("Duration")
                }
                Text("Block main thread for \(Int(hangDuration))s. Real data shows longer hangs (15s+) tend to get watchdog-killed instead of producing a diagnostic — this range aims for \"severe enough to flag\" without crossing into a kill.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Button {
                    StressSimulators.hangMainThread(duration: hangDuration)
                    statusMessage = "Simulated a \(Int(hangDuration))s main-thread hang."
                } label: {
                    Label("Simulate Hang", systemImage: "hourglass")
                }

                Button(role: .destructive) {
                    showForeverHangConfirmation = true
                } label: {
                    Label("Simulate Forever Hang", systemImage: "infinity")
                }
            }

            Section("5. Excess Disk Write (diskIOMetrics / diskSpaceUsageMetrics / diskWriteExceptionDiagnostics)") {
                Slider(value: $diskDuration, in: 10...60, step: 5) {
                    Text("Duration")
                }
                Text("Continuously write 10 MB chunks for \(Int(diskDuration))s. Real diagnostics need a large total write volume, not just a few files.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Button {
                    isChurningDisk = true
                    StressSimulators.diskChurn(duration: diskDuration) {
                        isChurningDisk = false
                        statusMessage = "Disk write churn complete (\(Int(diskDuration))s)."
                    }
                } label: {
                    Label(isChurningDisk ? "Writing…" : "Simulate Disk Writes", systemImage: "internaldrive")
                }
                .disabled(isChurningDisk)

                Text("diskWriteExceptionDiagnostics is the disk equivalent of the CPU exception above — it needs the OS to kill the app for excessive writes *while backgrounded*. Tap below, then immediately background the app and leave it for a minute or two.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Button {
                    isAbusingDiskInBackground = true
                    StressSimulators.diskChurnInBackground { elapsed in
                        isAbusingDiskInBackground = false
                        statusMessage = "Background disk abuse ran for \(Int(elapsed))s without being killed. If the app instead relaunched fresh when you reopened it, that's a stronger sign — check Diagnostics after the next batch window."
                    }
                } label: {
                    Label(isAbusingDiskInBackground ? "Running…" : "Abuse Disk in Background", systemImage: "internaldrive.fill")
                }
                .disabled(isAbusingDiskInBackground)
            }

            Section("Network Usage (networkTransferMetrics)") {
                Button {
                    isTransferringNetwork = true
                    StressSimulators.networkTransfer { success in
                        isTransferringNetwork = false
                        statusMessage = success ? "Network transfer complete." : "Network transfer failed."
                    }
                } label: {
                    Label(isTransferringNetwork ? "Transferring…" : "Simulate Network Transfer", systemImage: "network")
                }
                .disabled(isTransferringNetwork)
            }

            Section("Custom Signpost (signpostMetrics)") {
                Button {
                    if signpostActive {
                        signposts.end()
                        statusMessage = "Ended signpost interval \"MatricKitPocInterval\"."
                    } else {
                        signposts.begin()
                        statusMessage = "Began signpost interval \"MatricKitPocInterval\"."
                    }
                    signpostActive.toggle()
                } label: {
                    Label(signpostActive ? "End Signpost Interval" : "Begin Signpost Interval", systemImage: signpostActive ? "stop.circle" : "play.circle")
                }
            }

            if let statusMessage {
                Section("Status") {
                    Text(statusMessage)
                }
            }
        }
        .alert("Trigger a Test Crash?", isPresented: $showCrashConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Crash Now", role: .destructive) {
                StressSimulators.triggerCrash()
            }
        } message: {
            Text("This force-quits the app so iOS can generate an MXCrashDiagnostic. Relaunch afterward and check the Diagnostics section, or tap Load Past Payloads in the Dashboard section.")
        }
        .alert("Hang Forever?", isPresented: $showForeverHangConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Hang Forever", role: .destructive) {
                StressSimulators.hangMainThreadForever()
            }
        } message: {
            Text("This blocks the main thread indefinitely — the app will become fully unresponsive. You'll need to force-quit it (swipe up in the app switcher) to recover.")
        }
        .bttTrack("\(Self.self)")
    }
}

#Preview {
    TriggersView()
}
