//
//  ErrorLogView.swift
//  Example-SwiftUI
//
//  Lists every err.rcv payload the SDK has sent, with a Copy button that
//  puts the full request body on the pasteboard.
//

import SwiftUI
import UIKit

struct ErrorLogView: View {
    @ObservedObject private var log = ErrorRcvLog.shared
    @State private var copiedID: UUID?

    var body: some View {
        List {
            if log.entries.isEmpty {
                Text("No err.rcv requests captured yet.")
                    .foregroundColor(.gray)
            }

            ForEach(log.entries) { entry in
                NavigationLink {
                    ErrorLogDetailView(entry: entry)
                } label: {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(entry.errorType)
                                .font(.headline)
                            Text(entry.date.formatted(date: .abbreviated, time: .standard))
                                .font(.caption)
                                .foregroundColor(.gray)
                            if !entry.message.isEmpty {
                                Text(entry.message)
                                    .font(.subheadline)
                                    .lineLimit(2)
                            }
                        }
                        Spacer()
                        Button(copiedID == entry.id ? "Copied" : "Copy") {
                            copy(entry)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.blue)
                        .accessibilityIdentifier("copy_error_rcv")
                    }
                }
            }
            .onDelete { offsets in
                log.delete(at: offsets)
            }
        }
        .navigationTitle("Error Logs")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Clear") { log.clear() }
                    .disabled(log.entries.isEmpty)
            }
        }
    }

    private func copy(_ entry: ErrorRcvEntry) {
        UIPasteboard.general.string = entry.body
        copiedID = entry.id
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if copiedID == entry.id { copiedID = nil }
        }
    }
}

struct ErrorLogDetailView: View {
    let entry: ErrorRcvEntry
    @State private var copied = false

    var body: some View {
        ScrollView {
            Text(entry.body)
                .font(.system(.footnote, design: .monospaced))
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
        }
        .navigationTitle(entry.errorType)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(copied ? "Copied" : "Copy") {
                    UIPasteboard.general.string = entry.body
                    copied = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { copied = false }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ErrorLogView()
    }
}
