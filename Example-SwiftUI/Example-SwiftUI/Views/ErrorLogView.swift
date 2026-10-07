//
//  ErrorLogView.swift
//  Example-SwiftUI
//
//  Lists every err.rcv payload the SDK has sent, with a Copy button that
//  puts the full request body on the pasteboard, and lets payloads be mailed
//  as .json attachments named after their error type.
//

import MessageUI
import SwiftUI
import BlueTriangle
import UIKit

struct ErrorLogView: View {
    @ObservedObject private var log = ErrorRcvLog.shared
    @State private var copiedID: UUID?
    @State private var mailRequest: ErrorMailRequest?

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
                            Text(entry.displayName)
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
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    mailRequest = ErrorMailRequest(entries: log.entries)
                } label: {
                    Image(systemName: "envelope")
                }
                .disabled(log.entries.isEmpty)
                .accessibilityIdentifier("mail_all_error_rcv")

                Button("Clear") { log.clear() }
                    .disabled(log.entries.isEmpty)
            }
        }
        .errorMailSheet(item: $mailRequest)
        .bttTrack("\(Self.self)")
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
    @State private var mailRequest: ErrorMailRequest?

    var body: some View {
        ScrollView {
            Text(entry.body)
                .font(.system(.footnote, design: .monospaced))
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
        }
        .navigationTitle(entry.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    mailRequest = ErrorMailRequest(entries: [entry])
                } label: {
                    Image(systemName: "envelope")
                }
                .accessibilityIdentifier("mail_error_rcv")

                Button(copied ? "Copied" : "Copy") {
                    UIPasteboard.general.string = entry.body
                    copied = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { copied = false }
                }
            }
        }
        .errorMailSheet(item: $mailRequest)
        .bttTrack("\(Self.self)")
    }
}

// MARK: - Mail

private extension View {
    /// Presents the Mail composer, or the share sheet when Mail isn't set up
    /// on this device (e.g. the Simulator).
    func errorMailSheet(item: Binding<ErrorMailRequest?>) -> some View {
        sheet(item: item) { request in
            if MFMailComposeViewController.canSendMail() {
                MailComposeView(request: request)
                    .ignoresSafeArea()
            } else {
                ShareSheet(items: request.writeTemporaryFiles())
                    .ignoresSafeArea()
            }
        }
    }
}

private struct MailComposeView: UIViewControllerRepresentable {
    let request: ErrorMailRequest
    @Environment(\.dismiss) private var dismiss

    func makeCoordinator() -> Coordinator {
        Coordinator(dismiss: { dismiss() })
    }

    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        request.makeMailComposeViewController(delegate: context.coordinator)
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}

    final class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let dismiss: () -> Void

        init(dismiss: @escaping () -> Void) {
            self.dismiss = dismiss
        }

        func mailComposeController(_ controller: MFMailComposeViewController,
                                   didFinishWith result: MFMailComposeResult,
                                   error: Error?) {
            dismiss()
        }
    }
}

private struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    NavigationStack {
        ErrorLogView()
    }
}
