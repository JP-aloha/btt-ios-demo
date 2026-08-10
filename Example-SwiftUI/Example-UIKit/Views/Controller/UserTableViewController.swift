//
//  UserTableViewController.swift
//
//  Root screen for the User tab — a plain table of three rows (Profile,
//  Order History, Favourite), each pushing its own native view controller.
//  Copyright © 2026 Blue Triangle. All rights reserved.
//

import UIKit
import BlueTriangle

final class UserTableViewController: UITableViewController {

    private enum Row: Int, CaseIterable {
        case profile
        case orderHistory
        case favourite

        var title: String {
            switch self {
            case .profile: return "Profile"
            case .orderHistory: return "Order History"
            case .favourite: return "Favourite"
            }
        }

        var iconName: String {
            switch self {
            case .profile: return "person.crop.circle"
            case .orderHistory: return "bag"
            case .favourite: return "heart"
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "User"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UserRowCell")
    }

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Row.allCases.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserRowCell", for: indexPath)
        guard let row = Row(rawValue: indexPath.row) else { return cell }
        var content = cell.defaultContentConfiguration()
        content.text = row.title
        content.image = UIImage(systemName: row.iconName)
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let row = Row(rawValue: indexPath.row) else { return }
        switch row {
        case .profile:
            navigationController?.pushViewController(LoginViewController(), animated: true)
        case .orderHistory:
            navigationController?.pushViewController(OrderHistoryViewController(), animated: true)
        case .favourite:
            navigationController?.pushViewController(FavouriteViewController(), animated: true)
        }
    }
}
