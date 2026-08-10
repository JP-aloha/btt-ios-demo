//
//  FavouriteViewController.swift
//
//  Copyright © 2026 Blue Triangle. All rights reserved.
//

import UIKit

final class FavouriteViewController: UITableViewController {

    private let favorites = FavoriteItemFactory.defaultFavorites()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Favourite"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "FavoriteCell")
        tableView.rowHeight = 76
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        favorites.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteCell", for: indexPath)
        let item = favorites[indexPath.row]

        var content = cell.defaultContentConfiguration()
        content.text = item.name
        content.textProperties.font = .preferredFont(forTextStyle: .headline)
        content.secondaryText = item.category
        content.secondaryTextProperties.color = .secondaryLabel
        content.secondaryTextProperties.font = .preferredFont(forTextStyle: .caption1)
        // Deliberately expensive synchronous render — most rows hitch
        // (<750ms), every 15th row hangs (>750ms), see
        // StressSimulators.hitchOrHangCellImage — same image used by the
        // SwiftUI target's row.
        content.image = StressSimulators.hitchOrHangCellImage(index: indexPath.row)
        content.imageProperties.maximumSize = CGSize(width: 60, height: 60)
        content.imageProperties.cornerRadius = 8
        cell.contentConfiguration = content

        cell.accessoryView = makeTrailingView(price: item.price)
        cell.selectionStyle = .none
        return cell
    }

    /// Price + red heart, matching the SwiftUI target's trailing VStack for
    /// the same favourite row.
    private func makeTrailingView(price: Double) -> UIView {
        let priceLabel = UILabel()
        priceLabel.text = String(format: "$%.2f", price)
        priceLabel.font = .boldSystemFont(ofSize: 14)
        priceLabel.textAlignment = .right

        let heartView = UIImageView(image: UIImage(systemName: "heart.fill"))
        heartView.tintColor = .systemRed
        heartView.contentMode = .scaleAspectFit
        heartView.translatesAutoresizingMaskIntoConstraints = false
        heartView.widthAnchor.constraint(equalToConstant: 18).isActive = true
        heartView.heightAnchor.constraint(equalToConstant: 18).isActive = true

        let stack = UIStackView(arrangedSubviews: [priceLabel, heartView])
        stack.axis = .vertical
        stack.alignment = .trailing
        stack.spacing = 4
        stack.frame = CGRect(x: 0, y: 0, width: 70, height: 44)
        return stack
    }
}
