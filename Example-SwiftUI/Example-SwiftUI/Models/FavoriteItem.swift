//
//  FavoriteItem.swift
//
//  Copyright © 2026 Blue Triangle. All rights reserved.
//

import Foundation

struct FavoriteItem: Identifiable {
    let id = UUID()
    let name: String
    let category: String
    let price: Double
}

enum FavoriteItemFactory {
    static func defaultFavorites(count: Int = 100) -> [FavoriteItem] {
        let categories = ["Electronics", "Apparel", "Home", "Outdoors", "Beauty"]
        let names = [
            "Noise Cancelling Headphones", "Leather Jacket", "Ceramic Mug Set",
            "Camping Tent", "Facial Serum", "Gaming Mouse", "Running Jacket",
            "Table Lamp", "Hiking Boots", "Skincare Kit"
        ]
        return (1...count).map { index in
            FavoriteItem(
                name: "\(names[index % names.count]) #\(index)",
                category: categories[index % categories.count],
                price: Double((index * 23) % 180) + 4.99
            )
        }
    }
}
