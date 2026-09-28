//
//  CrashTypesView.swift
//  Example-SwiftUI
//
//  Lists one trigger per SDK error type from CrashSimulators; tapping one
//  records its tag for Error Logs, then fires it immediately.
//

import SwiftUI
import BlueTriangle

struct CrashTypesView: View {
    @State private var statusMessage: String?

    var body: some View {
        List {
            Section {
                Label("Xcode's debugger intercepts crashes and suppresses MetricKit diagnostics. After installing, tap Stop in Xcode and relaunch from the device's home screen before triggering. Results appear in User → Error Logs.", systemImage: "info.circle")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }

            if let statusMessage {
                Section("Status") {
                    Text(statusMessage)
                }
            }

            ForEach(CrashSimulators.categories) { category in
                Section {
                    ForEach(category.types) { type in
                        Button {
                            ErrorRcvLog.shared.markPendingTrigger(errorType: category.errorType, tag: type.tag)
                            type.trigger { message in
                                statusMessage = message
                            }
                        } label: {
                            HStack {
                                Image(systemName: type.systemImage)
                                    .foregroundColor(.red)
                                    .frame(width: 28)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(type.title)
                                        .foregroundColor(.primary)
                                    Text(type.detail)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .accessibilityIdentifier("crash_\(type.id)")
                    }
                } header: {
                    Text(category.errorType)
                } footer: {
                    Text(category.footer)
                }
            }
        }
        .navigationTitle("Generate Crash")
        .navigationBarTitleDisplayMode(.inline)
        .bttTrack("\(Self.self)")
    }
}

#Preview {
    NavigationStack {
        CrashTypesView()
    }
}
