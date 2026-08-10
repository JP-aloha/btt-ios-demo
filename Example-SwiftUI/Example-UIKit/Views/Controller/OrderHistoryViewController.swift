//
//  OrderHistoryViewController.swift
//
//  Copyright © 2026 Blue Triangle. All rights reserved.
//

import UIKit

final class OrderHistoryViewController: UITableViewController {

    private let orders = OrderHistoryFactory.defaultOrders()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Order History"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "OrderCell")
        tableView.rowHeight = 76
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        orders.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderCell", for: indexPath)
        let order = orders[indexPath.row]

        var content = cell.defaultContentConfiguration()
        content.text = order.productName
        content.textProperties.font = .preferredFont(forTextStyle: .headline)
        content.secondaryText = "#\(order.orderNumber) · \(order.date.formatted(date: .abbreviated, time: .omitted))"
        content.secondaryTextProperties.color = .secondaryLabel
        content.secondaryTextProperties.font = .preferredFont(forTextStyle: .caption1)
        // Deliberately expensive synchronous render, always under the hang
        // threshold (see StressSimulators.hitchOnlyCellImage) — Order
        // History exercises hitch-rate detection only, same as the
        // SwiftUI target's row.
        content.image = StressSimulators.hitchOnlyCellImage(index: indexPath.row)
        content.imageProperties.maximumSize = CGSize(width: 60, height: 60)
        content.imageProperties.cornerRadius = 8
        cell.contentConfiguration = content

        cell.accessoryView = makeTrailingView(amount: order.amount, status: order.status)
        cell.selectionStyle = .none
        return cell
    }

    /// Price + colored status pill, matching the SwiftUI target's trailing
    /// VStack for the same order row.
    private func makeTrailingView(amount: Double, status: String) -> UIView {
        let priceLabel = UILabel()
        priceLabel.text = String(format: "$%.2f", amount)
        priceLabel.font = .boldSystemFont(ofSize: 14)
        priceLabel.textAlignment = .right

        let color = statusColor(status)
        let statusLabel = PaddedLabel()
        statusLabel.text = status
        statusLabel.font = .boldSystemFont(ofSize: 11)
        statusLabel.textColor = color
        statusLabel.backgroundColor = color.withAlphaComponent(0.15)
        statusLabel.layer.cornerRadius = 8
        statusLabel.layer.masksToBounds = true
        statusLabel.textAlignment = .center

        let stack = UIStackView(arrangedSubviews: [priceLabel, statusLabel])
        stack.axis = .vertical
        stack.alignment = .trailing
        stack.spacing = 4
        stack.frame = CGRect(x: 0, y: 0, width: 96, height: 44)
        return stack
    }

    private func statusColor(_ status: String) -> UIColor {
        switch status {
        case "Delivered": return .systemGreen
        case "Shipped": return .systemBlue
        case "Processing": return .systemOrange
        default: return .systemRed
        }
    }
}

/// UILabel with inset padding around its text — used for the pill-shaped
/// status badge, since UILabel has no built-in content insets.
private final class PaddedLabel: UILabel {
    private let inset = UIEdgeInsets(top: 3, left: 8, bottom: 3, right: 8)

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: inset))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + inset.left + inset.right, height: size.height + inset.top + inset.bottom)
    }
}
