//
//  OrderHistoryView.swift
//
//  Copyright © 2026 Blue Triangle. All rights reserved.
//

import SwiftUI
import BlueTriangle

struct OrderHistoryView: View {
    private let orders = OrderHistoryFactory.defaultOrders()

    var body: some View {
        List(orders.indices, id: \.self) { index in
            let order = orders[index]
            HStack(spacing: 12) {
                // Deliberately expensive synchronous render, always under
                // the hang threshold (see StressSimulators.hitchOnlyCellImage)
                // so scrolling this list produces real hitches but never a
                // hang — Order History exercises hitch-rate detection only.
                Image(uiImage: StressSimulators.hitchOnlyCellImage(index: index))
                    .resizable()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 4) {
                    Text(order.productName)
                        .font(.headline)
                    Text("#\(order.orderNumber) · \(order.date.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 6) {
                    Text(order.amount, format: .currency(code: "USD"))
                        .font(.subheadline.bold())
                    Text(order.status)
                        .font(.caption2.bold())
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(statusColor(order.status).opacity(0.15))
                        .foregroundStyle(statusColor(order.status))
                        .clipShape(Capsule())
                }
            }
            .padding(.vertical, 4)
        }
        .navigationTitle("Order History")
        .navigationBarTitleDisplayMode(.inline)
        .bttTrackScreen("OrderHistoryView")
        .bttTrack("\(Self.self)")
    }

    private func statusColor(_ status: String) -> Color {
        switch status {
        case "Delivered": return .green
        case "Shipped": return .blue
        case "Processing": return .orange
        default: return .red
        }
    }
}

#Preview {
    NavigationStack {
        OrderHistoryView()
    }
}
