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
    }
}

// MARK: - Mail

/// One or more payloads to send, each as its own
/// `<ErrorType>_<Tag>_<timestamp>.json` attachment.
struct ErrorMailRequest: Identifiable {
    struct Attachment {
        let fileName: String
        let data: Data
    }

    let id = UUID()
    let entries: [ErrorRcvEntry]

    private static let fileDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        return formatter
    }()

    var subject: String {
        entries.count == 1
            ? "BTT Error Payload - \(entries[0].displayName)"
            : "BTT Error Payloads (\(entries.count))"
    }

    var messageBody: String {
        let lines = entries.map { entry in
            var line = "• \(entry.displayName) — \(entry.date.formatted(date: .abbreviated, time: .standard))"
            if !entry.message.isEmpty {
                line += "\n  \(entry.message.replacingOccurrences(of: "\n", with: " "))"
            }
            return line
        }
        return "err.rcv payload(s) captured by eCom SwiftUI:\n\n" + lines.joined(separator: "\n\n")
    }

    var attachments: [Attachment] {
        var usedNames = Set<String>()
        return entries.map { entry in
            let parts = [entry.errorType, entry.tag ?? ""]
                .map { $0.components(separatedBy: CharacterSet.alphanumerics.inverted).filter { !$0.isEmpty }.joined(separator: "-") }
                .filter { !$0.isEmpty }
            let type = parts.isEmpty ? "Error" : parts.joined(separator: "_")
            let base = "\(type)_\(Self.fileDateFormatter.string(from: entry.date))"
            var name = "\(base).json"
            var suffix = 2
            while !usedNames.insert(name).inserted {
                name = "\(base)_\(suffix).json"
                suffix += 1
            }
            return Attachment(fileName: name, data: Data(entry.body.utf8))
        }
    }

    /// Writes the attachments to a temp folder for the share-sheet fallback.
    func writeTemporaryFiles() -> [URL] {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("ErrorLogMail", isDirectory: true)
        try? FileManager.default.removeItem(at: directory)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return attachments.compactMap { attachment in
            let url = directory.appendingPathComponent(attachment.fileName)
            return (try? attachment.data.write(to: url, options: .atomic)) != nil ? url : nil
        }
    }
}

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
        let controller = MFMailComposeViewController()
        controller.mailComposeDelegate = context.coordinator
        controller.setSubject(request.subject)
        controller.setMessageBody(request.messageBody, isHTML: false)
        for attachment in request.attachments {
            controller.addAttachmentData(attachment.data, mimeType: "application/json", fileName: attachment.fileName)
        }
        return controller
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
