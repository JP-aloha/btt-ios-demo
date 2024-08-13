//
//  CartItemRow.swift
//
//  Created by Mathew Gacy on 10/31/22.
//  Copyright © 2022 Blue Triangle. All rights reserved.
//

import Service
import SwiftUI

struct CartItemRow: View {
    @State var imageStatus: ImageStatus?
    let imageStatusProvider: (URL) async -> ImageStatus?
    let name: String
    let price: Double
    let quantity: Int
    let imageURL: URL
    let onIncrement: () -> Void
    let onDecrement: () -> Void
    let onRemove: () -> Void
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            if let imageStatus {
                RemoteImage(imageStatus: imageStatus)
                    .cornerRadius(8)
                    .frame(width: 64, height: 64)
            }

            VStack(alignment: .leading) {
                HStack {
                    Text(name)
                        .multilineTextAlignment(.leading)
                        .font(.headline)
                    Spacer()
                    Button {
                        onRemove()
                    } label: {
                        Image(systemName: "trash")
                            .tint(.red)
                    }
                    .accessibilityIdentifier("btn_remove")
                    .frame(width: 40, height: 40)
                }

                Text(price, format: .currency(code: "USD"))

                Stepper {
                    Text("\(quantity)")
                } onIncrement: {
                    onIncrement()
                } onDecrement: {
                    onDecrement()
                }
            }
        }
        .buttonStyle(.borderless)
        .task {
            if let status = await imageStatusProvider(imageURL) {
                imageStatus = status
            }
        }
    }
}

extension CartItemRow {
    init(
        imageStatusProvider: @escaping (URL) async -> ImageStatus?,
        item: CartItemModel,
        onIncrement: @escaping () -> Void = {},
        onDecrement: @escaping () -> Void = {},
        onRemove: @escaping () -> Void = {}
        
    ) {
        self.imageStatusProvider = imageStatusProvider
        self.name = item.product.name
        self.price = item.price
        self.quantity = item.quantity
        self.imageURL = item.product.image
        self.onIncrement = onIncrement
        self.onDecrement = onDecrement
        self.onRemove = onRemove
    }
}

struct CartItemRow_Previews: PreviewProvider {
    static var previews: some View {
        CartItemRow(
            imageStatusProvider: { _ in
                .downloaded(.success(UIColor.random().image()))
            },
            item: CartItemModel(
                id: 1,
                quantity: 1,
                product: Mock.product))
        .previewLayout(.sizeThatFits)
    }
}
