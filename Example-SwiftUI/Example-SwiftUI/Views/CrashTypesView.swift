//
//  CrashTypesView.swift
//  Example-SwiftUI
//
//  Lists every crash / error type from CrashSimulators; tapping one asks
//  for confirmation, then triggers it.
//

import SwiftUI
import BlueTriangle

struct CrashTypesView: View {
    @State private var pending: CrashType?

    var body: some View {
        List {
            Section {
                Label("Crashes are intercepted by Xcode's debugger. After installing, tap Stop in Xcode and relaunch from the device's home screen before triggering. The crash report is uploaded on the next launch — check User → Error Logs.", systemImage: "info.circle")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }

            ForEach(CrashSimulators.categories) { category in
                Section {
                    ForEach(category.types) { type in
                        Button {
                            pending = type
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
                    Text(category.title)
                } footer: {
                    Text(category.footer)
                }
            }
        }
        .navigationTitle("Generate Crash")
        .navigationBarTitleDisplayMode(.inline)
        .alert(
            pending?.title ?? "",
            isPresented: Binding(get: { pending != nil }, set: { if !$0 { pending = nil } }),
            presenting: pending
        ) { type in
            Button("Cancel", role: .cancel) {}
            Button("Crash Now", role: .destructive) {
                type.trigger()
            }
        } message: { type in
            Text("\(type.detail).\n\nThis terminates the app. Relaunch it so the SDK can upload the crash report.")
        }
        .bttTrack("\(Self.self)")
    }
}

#Preview {
    NavigationStack {
        CrashTypesView()
    }
}
