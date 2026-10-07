//
//  ErrorMailRequest.swift
//  Example-SwiftUI
//
//  Builds the mail for one or more Error Logs entries — subject, body and
//  one `<ErrorType>_<Tag>_<timestamp>.json` attachment per entry. Shared by
//  the SwiftUI and UIKit Error Logs screens.
//

import MessageUI
import UIKit

/// One or more payloads to send, each as its own
/// `<ErrorType>_<Tag>_<timestamp>.json` attachment.
struct ErrorMailRequest: Identifiable {
    struct Attachment {
        let fileName: String
        let data: Data
    }

    let id = UUID()
    let entries: [ErrorRcvEntry]

    private static var appName: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
            ?? Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
            ?? "the app"
    }

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
        return "err.rcv payload(s) captured by \(Self.appName):\n\n" + lines.joined(separator: "\n\n")
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

// MARK: - Presenting

extension ErrorMailRequest {
    func makeMailComposeViewController(delegate: MFMailComposeViewControllerDelegate) -> MFMailComposeViewController {
        let controller = MFMailComposeViewController()
        controller.mailComposeDelegate = delegate
        controller.setSubject(subject)
        controller.setMessageBody(messageBody, isHTML: false)
        for attachment in attachments {
            controller.addAttachmentData(attachment.data, mimeType: "application/json", fileName: attachment.fileName)
        }
        return controller
    }

    /// UIKit: presents the Mail composer, or the share sheet when Mail isn't
    /// set up on this device (e.g. the Simulator).
    func present(from presenter: UIViewController, sourceItem: UIBarButtonItem? = nil) {
        if MFMailComposeViewController.canSendMail() {
            presenter.present(makeMailComposeViewController(delegate: MailComposeDismisser.shared), animated: true)
        } else {
            let share = UIActivityViewController(activityItems: writeTemporaryFiles(), applicationActivities: nil)
            share.popoverPresentationController?.barButtonItem = sourceItem
            presenter.present(share, animated: true)
        }
    }
}

private final class MailComposeDismisser: NSObject, MFMailComposeViewControllerDelegate {
    static let shared = MailComposeDismisser()

    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult,
                               error: Error?) {
        controller.dismiss(animated: true)
    }
}
