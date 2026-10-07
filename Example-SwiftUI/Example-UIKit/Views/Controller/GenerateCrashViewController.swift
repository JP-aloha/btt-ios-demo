//
//  GenerateCrashViewController.swift
//
//  Native UIKit version of the SwiftUI CrashTypesView — one section per SDK
//  error type from CrashSimulators; tapping a row records its tag for Error
//  Logs, then fires it immediately.
//  Copyright © 2026 Blue Triangle. All rights reserved.
//

import UIKit

final class GenerateCrashViewController: UITableViewController {

    private enum Section {
        case info
        case status(String)
        case category(CrashCategory)
    }

    private var statusMessage: String?

    private var sections: [Section] {
        var sections: [Section] = [.info]
        if let statusMessage {
            sections.append(.status(statusMessage))
        }
        sections += CrashSimulators.categories.map(Section.category)
        return sections
    }

    init() {
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Generate Crash"
        navigationItem.largeTitleDisplayMode = .never
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "GenerateCrashCell")
    }

    // MARK: - UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch sections[section] {
        case .info, .status: return 1
        case .category(let category): return category.types.count
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch sections[section] {
        case .info: return nil
        case .status: return "Status"
        case .category(let category): return category.errorType
        }
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if case .category(let category) = sections[section] {
            return category.footer
        }
        return nil
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GenerateCrashCell", for: indexPath)
        var content = UIListContentConfiguration.subtitleCell()
        cell.selectionStyle = .none
        cell.accessibilityIdentifier = nil

        switch sections[indexPath.section] {
        case .info:
            content.image = UIImage(systemName: "info.circle")
            content.imageProperties.tintColor = .systemOrange
            content.text = "Xcode's debugger intercepts crashes and suppresses MetricKit diagnostics. After installing, tap Stop in Xcode and relaunch from the device's home screen before triggering. Results appear in User → Error Logs."
            content.textProperties.font = .preferredFont(forTextStyle: .caption1)
            content.textProperties.color = .systemOrange
        case .status(let message):
            content.text = message
        case .category(let category):
            let type = category.types[indexPath.row]
            content.image = UIImage(systemName: type.systemImage)
            content.imageProperties.tintColor = .systemRed
            content.imageProperties.reservedLayoutSize = CGSize(width: 28, height: 0)
            content.text = type.title
            content.secondaryText = type.detail
            content.secondaryTextProperties.font = .preferredFont(forTextStyle: .caption1)
            content.secondaryTextProperties.color = .secondaryLabel
            cell.selectionStyle = .default
            cell.accessibilityIdentifier = "crash_\(type.id)"
        }
        cell.contentConfiguration = content
        return cell
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if case .category = sections[indexPath.section] { return true }
        return false
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard case .category(let category) = sections[indexPath.section] else { return }
        let type = category.types[indexPath.row]
        ErrorRcvLog.shared.markPendingTrigger(errorType: category.errorType, tag: type.tag)
        type.trigger { [weak self] message in
            self?.statusMessage = message
            self?.tableView.reloadData()
        }
    }
}
