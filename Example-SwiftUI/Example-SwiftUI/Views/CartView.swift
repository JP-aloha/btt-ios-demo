//
//  CartView.swift
//
//  Created by Mathew Gacy on 10/27/22.
//  Copyright © 2022 Blue Triangle. All rights reserved.
//

import BlueTriangle
import IdentifiedCollections
import SwiftUI
import Service

struct CartView: View {
    private let imageLoader: ImageLoader
    @ObservedObject var viewModel: CartViewModel
    @ObservedObject var userModel: UserViewModel
    @State var didPlaceOrder = false
    @State var  timer : BTTimer?
   
    init(imageLoader: ImageLoader, viewModel: CartViewModel, userModel : UserViewModel ) {
        self.imageLoader = imageLoader
        self.viewModel = viewModel
        self.userModel = userModel
    }

    var body: some View {
        NavigationStack {
            Group {

                    cartList(viewModel)
                        .padding(.bottom, 60)
                        .overlay(alignment: .bottom) {
                            Button(
                                action: {
                                    if viewModel.productItems.count > 4 {
                                        ANRTest.cartLimitExceedCrash()
                                    } else if viewModel.productItems.isEmpty {
                                        ANRTest.emptyCartCrash()
                                    }
                                    Task {
                                        await viewModel.checkout()
                                        await viewModel.placeOrder()
                                        didPlaceOrder = true
                                    }
                                },
                                label: {
                                    Text("Checkout")
                                })
                            .accessibilityIdentifier("checkout")
                            .buttonStyle(.primary())
                            .padding()
                        }//.disabled(viewModel.isLoading)
                    .bttTrackScreen("CartView")
                    .onAppear{
                        let isScreenTracking : Bool = UserDefaults.standard.bool(forKey: ConfigUserDefaultKeys.ConfigScreenTrackingKey)
                        if !isScreenTracking, BlueTriangle.initialized{
                            self.timer = BlueTriangle.startTimer(
                                page: Page(
                                    pageName: "CartView Mannual Tracking"))
                        }
                    }
                    .onDisappear {
                        let isScreenTracking : Bool = UserDefaults.standard.bool(forKey: ConfigUserDefaultKeys.ConfigScreenTrackingKey)
                        if let timer = self.timer, !isScreenTracking, BlueTriangle.initialized{
                            BlueTriangle.endTimer(timer)
                        }
                    }
                    
           //     }
            }
            .navigationDestination(isPresented: $didPlaceOrder, destination: {
                OrderSuccessfulView(checkoutId: viewModel.checkoutItem?.confirmation ?? UUID().uuidString)
            })
            .alert("Detected memory warning.", isPresented: $viewModel.isMemoryWarning) {
                Button("OK", role: .cancel) { }
            }
            .navigationTitle("Cart")
        }
        .errorAlert(error: $viewModel.error)
    }
}

private extension CartView {
    func footer(estimatedTax: Double, subtotal: Double) -> some View {
        VStack(spacing: 8) {
            LineItemRow(
                title: "Estimated tax",
                value: estimatedTax)

            LineItemRow(
                title: "Subtotal",
                value: subtotal) {
                    $0.bold()
                }
        }
    }

    func cartList(_ viewModel: CartViewModel) -> some View {
        List {
            ForEach(viewModel.productItems) { productItem in
                CartItemRow(
                    imageStatusProvider: { await imageLoader.images[$0] },
                    item: productItem,
                    onIncrement: {
                        Task {
                            await viewModel.increment(id: productItem.id)
                        }
                    },
                    onDecrement: {
                        Task {
                            await viewModel.decrement(id: productItem.id)
                        }
                    },
                    onRemove: {
                        Task {
                            
                             ANRTest.removeCartItem()
                            await viewModel.removeProduct(id: productItem.id)
                            
                        }
                    })
            }

//            Section {
//
//                footer(
//                    estimatedTax: viewModel.estimatedTax,
//                    subtotal: viewModel.subtotal)
//            }
        }
    }
}

struct CartView_Previews: PreviewProvider {
    static var previews: some View {
        CartView(
            imageLoader: .mock,
            viewModel: .init(
                service: .mock,
                cartRepository: .mock
            ), userModel: UserViewModel())
    }
}
