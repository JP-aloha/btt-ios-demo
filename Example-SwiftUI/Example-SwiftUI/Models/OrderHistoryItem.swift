//
//  OrderHistoryItem.swift
//
//  Copyright © 2026 Blue Triangle. All rights reserved.
//

import Foundation

struct OrderHistoryItem: Identifiable {
    let id = UUID()
    let orderNumber: String
    let productName: String
    let date: Date
    let amount: Double
    let status: String
}

enum OrderHistoryFactory {
    static func defaultOrders(count: Int = 100) -> [OrderHistoryItem] {
        let statuses = ["Delivered", "Shipped", "Processing", "Cancelled"]
        let products = [
            "Wireless Headphones", "Running Shoes", "Coffee Maker", "Backpack",
            "Smart Watch", "Desk Lamp", "Yoga Mat", "Bluetooth Speaker",
            "Sunglasses", "Water Bottle"
        ]
        return (1...count).map { index in
            OrderHistoryItem(
                orderNumber: String(format: "ORD-%05d", index),
                productName: products[index % products.count],
                date: Calendar.current.date(byAdding: .day, value: -index, to: Date()) ?? Date(),
                amount: Double((index * 37) % 250) + 9.99,
                status: statuses[index % statuses.count]
            )
        }
    }
}
