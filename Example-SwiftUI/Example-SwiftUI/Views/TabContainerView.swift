//
//  TabContainerView.swift
//
//  Created by Mathew Gacy on 10/27/22.
//  Copyright © 2022 Blue Triangle. All rights reserved.
//

import Service
import SwiftUI

struct TabContainerView: View {
    enum Tab: Hashable {
        case products
        case cart
        case settings
    }
   
    @State private var selectedTab: Tab = .products
    private let cartRepository: CartRepository
    private let imageLoader: ImageLoader
    private let service: Service
    @ObservedObject var vm: BTTConfigModel
    @ObservedObject var userModel = UserViewModel()
    @ObservedObject var productModel : ProductListViewModel
    @ObservedObject var cartModel : CartViewModel
    @ObservedObject var settingModel : SettingsViewModel

    init(imageLoader: ImageLoader, service: Service, vm : BTTConfigModel) {
        self.imageLoader = imageLoader
        self.service = service
        self.vm = vm
        self.cartRepository = CartRepository(service: service)
        self.productModel = ProductListViewModel(cartRepository: cartRepository, imageLoader: imageLoader, service: service)
        self.cartModel = CartViewModel(service: service, cartRepository: cartRepository)
        self.settingModel = SettingsViewModel()
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            ProductListView(
                viewModel: productModel,
                userModel: userModel)
                .bttTrackScreen("ProductListViewTab")
                .tabItem {
                    Text("Products")
                    Image(systemName: "square.grid.2x2.fill")
                 }
                .tag(Tab.products)

            CartView(
                imageLoader: imageLoader,
                viewModel:cartModel,
                userModel: userModel)
                .bttTrackScreen("CartViewTab")
                .tabItem {
                    Text("Cart")
                    Image(systemName: "cart.fill")
                 }
                .tag(Tab.cart)

            SettingsView(vm: settingModel,
                         userModel: userModel)
                .bttTrackScreen("SettingsViewTab")
                .tabItem {
                    Text("Settings")
                    Image(systemName: "gearshape.fill")
                 }
                .tag(Tab.settings)
        }
    }
}

struct TabContainerView_Previews: PreviewProvider {
    static var previews: some View {
        TabContainerView(imageLoader: .mock, service: .mock, vm: BTTConfigModel())
    }
}
