//
//  ProductDetailView.swift
//
//  Created by Mathew Gacy on 10/27/22.
//  Copyright © 2022 Blue Triangle. All rights reserved.
//

import Service
import SwiftUI
import BlueTriangle

struct ProductDetailView: View {
    @ObservedObject var viewModel: ProductDetailViewModel
    @State var imageStatus: ImageStatus?
    @State var isLoading: Bool = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            VStack {
                if let imageStatus = imageStatus {
                    RemoteImage(imageStatus: imageStatus)
                }

                VStack(alignment: .leading, spacing: 16) {
                    header(viewModel)

                    Text(viewModel.description)
                        .font(.body)

                    Spacer()
                        .frame(height: 72)
                }
                .padding(.horizontal, 16)
            }
        }
        .navigationBarBackButtonHidden(true)
        .bttTrackScreen("ProductDetailView")
        .toolbar {
                   ToolbarItem(placement: .navigationBarLeading) {
                       Button(action: {
                           presentationMode.wrappedValue.dismiss()
                       }) {
                           HStack {
                               Image(systemName: "chevron.left")
                               Text("Products")
                           }
                       }
                       .accessibilityIdentifier("back")
                   }
               }
        .overlay(alignment: .bottom) {
            Button(
                action: {
                    viewModel.quantity += 1
                    if viewModel.hasCrashLimitExceed() {
                            ANRTest.quantityLimitExceedCrash()
                    }
                    
                    Task {
                        isLoading = true
                        await viewModel.addToCart()
                        isLoading = false
                    }
                },
                label: {
                    Text("Add to Cart")
                }).disabled(isLoading)
                .accessibilityIdentifier("add to cart")
            .buttonStyle(.primary())
            .padding()
        }
        .task {
            if let status = await viewModel.imageStatus() {
                imageStatus = status
            }
        }
        .alert("Memory Warning", isPresented: $viewModel.isMemoryWarning, actions: {
            Button("OK", role: .cancel) { }
        }, message: {
           Text("Memory warning received. Your app is using too much memory than expected.")
        })
        .onAppear(perform: {
            ConfigurationSetup.configOnOtherScreen()
        })
        .onDisappear{
            viewModel.freeAllMemoryOnDisapear()
        }
        .navigationTitle("Product Detail")
        //.navigationBarTitleDisplayMode(.inline)
    }
}

private extension ProductDetailView {
    @ViewBuilder
    func header(_ viewModel:  ProductDetailViewModel) -> some View {
        VStack(spacing: 8) {
            HStack(alignment: .bottom) {
                Text(viewModel.name)
                    .font(.title2)

                Spacer()

                Text(viewModel.price)
            }

//            HStack(spacing: 0) {
//                Text("Qty:")

//                Picker("Quantity",
//                       selection: $viewModel.quantity) {
//                    ForEach(1..<5) { Text("\($0)").tag($0) }
//                }
//
//                Spacer()
//            }
        }
    }
}

struct ProductDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ProductDetailView(
            viewModel: .init(
                cartRepository: .mock,
                imageLoader: .mock,
                product: Mock.product))
    }
}
