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

        var iconName: String {
            switch self {
            case .profile: return "person.crop.circle.fill"
            case .orderHistory: return "bag"
            case .favourite: return "heart"
            }
        }
    }

    private let userModel = UserViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "User"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UserRowCell")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Re-read on every appearance (including popping back from
        // LoginViewController after a login/logout) rather than once at
        // load, since that screen owns its own UserViewModel instance and
        // won't otherwise notify this one.
        tableView.reloadData()
    }

    private func title(for row: Row) -> String {
        switch row {
        case .profile: return userModel.loggedInUser()?.name ?? "Guest User"
        case .orderHistory: return "Order History"
        case .favourite: return "Favourite"
        }
    }

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Row.allCases.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserRowCell", for: indexPath)
        guard let row = Row(rawValue: indexPath.row) else { return cell }
        var content = cell.defaultContentConfiguration()
        content.text = title(for: row)
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
