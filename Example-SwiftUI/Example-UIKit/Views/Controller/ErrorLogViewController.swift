//
//  ErrorLogViewController.swift
//
//  Native UIKit version of the SwiftUI ErrorLogView — every err.rcv payload
//  the SDK has sent, with Copy, swipe-to-delete, Clear, and Mail (all
//  payloads as `<ErrorType>_<Tag>_<timestamp>.json` attachments).
//  Copyright © 2026 Blue Triangle. All rights reserved.
//

import Combine
import UIKit

final class ErrorLogViewController: UITableViewController {

    private let log = ErrorRcvLog.shared
    private var entries: [ErrorRcvEntry] = []
    private var copiedID: UUID?
    private var subscription: AnyCancellable?

    private lazy var mailButton = UIBarButtonItem(
        image: UIImage(systemName: "envelope"),
        primaryAction: UIAction { [weak self] _ in self?.mailAll() }
    )
    private lazy var clearButton = UIBarButtonItem(
        title: "Clear",
        primaryAction: UIAction { [weak self] _ in self?.log.clear() }
    )
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "No err.rcv requests captured yet."
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()

    init() {
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Error Logs"
        navigationItem.largeTitleDisplayMode = .never
        mailButton.accessibilityIdentifier = "mail_all_error_rcv"
        navigationItem.rightBarButtonItems = [clearButton, mailButton]
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ErrorLogCell")

        subscription = log.$entries
            .receive(on: DispatchQueue.main)
            .sink { [weak self] entries in
                self?.entries = entries
                self?.reload()
            }
    }

    private func reload() {
        tableView.reloadData()
        tableView.backgroundView = entries.isEmpty ? emptyLabel : nil
        mailButton.isEnabled = !entries.isEmpty
        clearButton.isEnabled = !entries.isEmpty
    }

    private func mailAll() {
        ErrorMailRequest(entries: entries).present(from: self, sourceItem: mailButton)
    }

    private func copy(_ entry: ErrorRcvEntry) {
        UIPasteboard.general.string = entry.body
        copiedID = entry.id
        tableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self, self.copiedID == entry.id else { return }
            self.copiedID = nil
            self.tableView.reloadData()
        }
    }

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        entries.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ErrorLogCell", for: indexPath)
        let entry = entries[indexPath.row]

        var content = UIListContentConfiguration.subtitleCell()
        content.text = entry.displayName
        content.textProperties.font = .preferredFont(forTextStyle: .headline)
        var secondary = entry.date.formatted(date: .abbreviated, time: .standard)
        if !entry.message.isEmpty {
            secondary += "\n" + entry.message
        }
        content.secondaryText = secondary
        content.secondaryTextProperties.numberOfLines = 3
        content.secondaryTextProperties.color = .secondaryLabel
        cell.contentConfiguration = content

        var buttonConfiguration = UIButton.Configuration.filled()
        buttonConfiguration.title = copiedID == entry.id ? "Copied" : "Copy"
        buttonConfiguration.buttonSize = .small
        let copyButton = UIButton(configuration: buttonConfiguration, primaryAction: UIAction { [weak self] _ in
            self?.copy(entry)
        })
        copyButton.accessibilityIdentifier = "copy_error_rcv"
        copyButton.sizeToFit()
        cell.accessoryView = copyButton
        return cell
    }

    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        log.delete(at: IndexSet(integer: indexPath.row))
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        navigationController?.pushViewController(ErrorLogDetailViewController(entry: entries[indexPath.row]), animated: true)
    }
}

// MARK: - Detail

final class ErrorLogDetailViewController: UIViewController {

    private let entry: ErrorRcvEntry

    private lazy var copyButton = UIBarButtonItem(
        title: "Copy",
        primaryAction: UIAction { [weak self] _ in self?.copyBody() }
    )
    private lazy var mailButton = UIBarButtonItem(
        image: UIImage(systemName: "envelope"),
        primaryAction: UIAction { [weak self] _ in self?.mail() }
    )

    init(entry: ErrorRcvEntry) {
        self.entry = entry
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = entry.displayName
        navigationItem.largeTitleDisplayMode = .never
        mailButton.accessibilityIdentifier = "mail_error_rcv"
        navigationItem.rightBarButtonItems = [copyButton, mailButton]
        view.backgroundColor = .systemBackground

        let textView = UITextView()
        textView.text = entry.body
        textView.font = .monospacedSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .footnote).pointSize, weight: .regular)
        textView.isEditable = false
        textView.isSelectable = true
        textView.alwaysBounceVertical = true
        textView.textContainerInset = UIEdgeInsets(top: 16, left: 12, bottom: 16, right: 12)
        textView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textView)
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.topAnchor),
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }

    private func mail() {
        ErrorMailRequest(entries: [entry]).present(from: self, sourceItem: mailButton)
    }

    private func copyBody() {
        UIPasteboard.general.string = entry.body
        copyButton.title = "Copied"
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.copyButton.title = "Copy"
        }
    }
}
