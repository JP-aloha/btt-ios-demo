//
//  CheckoutView.swift
//
//  Created by Mathew Gacy on 10/27/22.
//  Copyright © 2022 Blue Triangle. All rights reserved.
//

import Service
import SwiftUI
import BlueTriangle

struct CheckoutView: View {
    @ObservedObject var viewModel: CheckoutViewModel
    @Binding var didPlaceOrder: Bool
    
    init(viewModel: CheckoutViewModel, didPlaceOrder: Binding<Bool>) {
        self.viewModel = viewModel
        self._didPlaceOrder = didPlaceOrder
    }

    var body: some View {
        VStack {
            rows(viewModel)
                .padding(.top, 32)

            Spacer()

            Button(
                action: {
                    Task {
                        await viewModel.placeOrder()
                        didPlaceOrder = !didPlaceOrder
                    }
                },
                label: {
                    Text("Place Order")
                })
            .buttonStyle(.primary())
        }
        //.bttTrackScreen("CheckoutView")
        .padding()
        .errorAlert(error: $viewModel.error)
        .bttTrack("\(Self.self)")
    }
}

private extension CheckoutView {
    @ViewBuilder
    func rows(_ viewModel: CheckoutViewModel) -> some View {
        VStack(spacing: 8) {
            LineItemRow(
                title: "Items (\(viewModel.itemCount))",
                value: viewModel.itemTotal)
            LineItemRow(
                title: "Shipping & Handling",
                value: viewModel.shipping)
            LineItemRow(
                title: "Estimated tax",
                value: viewModel.estimatedTax)
            LineItemRow(
                title: "Order Total",
                value: viewModel.total)
            .bold()
        }
    }
}
//
//struct CheckoutView_Previews: PreviewProvider {
//    static var previews: some View {
//        CheckoutView(
//            viewModel: .init(
//                cartRepository: .mock,
//                checkout: Mock.checkout,
//                onFinish: {}
//            ), didPlaceOrder: $false)
//    }
//}
