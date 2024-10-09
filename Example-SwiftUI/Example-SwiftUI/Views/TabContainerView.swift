//
//  TabContainerView.swift
//
//  Created by Mathew Gacy on 10/27/22.
//  Copyright © 2022 Blue Triangle. All rights reserved.
//

import Service
import SwiftUI

struct TabContainerView: View {
	enum Tab: String, Hashable {
		case products = "Products"
		case cart	  = "Cart"
		case settings = "Settings"
	}
	
	@State private var selectedTab: Tab = .products
	private let cartRepository: CartRepository
	private let imageLoader: ImageLoader
	private let service: Service
	@ObservedObject var vm: BTTConfigModel
	@ObservedObject var productModel : ProductListViewModel
	@ObservedObject var cartModel : CartViewModel
	@ObservedObject var settingModel : SettingsViewModel
	@State private var showLoginSheet = false
	
	init(imageLoader: ImageLoader, service: Service, vm : BTTConfigModel, showLoginSheet: Bool = false) {
		self.imageLoader = imageLoader
		self.service = service
		self.vm = vm
		self.cartRepository = CartRepository(service: service)
		self.productModel = ProductListViewModel(cartRepository: cartRepository, imageLoader: imageLoader, service: service)
		self.cartModel = CartViewModel(service: service, cartRepository: cartRepository)
		self.settingModel = SettingsViewModel()
		self.showLoginSheet = showLoginSheet
	}
	
	var body: some View {
		NavigationStack {
			TabView(selection: $selectedTab) {
				ProductListView(
					viewModel: productModel)
				.bttTrackScreen("ProductListViewTab")
				.tabItem {
					Text("Products")
					Image(systemName: "square.grid.2x2.fill")
				}
				.tag(Tab.products)
				
				CartView(
					imageLoader: imageLoader,
					viewModel:cartModel)
				.bttTrackScreen("CartViewTab")
				.tabItem {
					Text("Cart")
					Image(systemName: "cart.fill")
				}
				.tag(Tab.cart)
				
				SettingsView(vm: settingModel)
				.bttTrackScreen("SettingsViewTab")
				.tabItem {
					Text("Settings")
					Image(systemName: "gearshape.fill")
				}
				.tag(Tab.settings)
			}
			.navigationTitle(selectedTab.rawValue)
			.toolbar {
				ToolbarItem(placement: .navigationBarTrailing) {
					HStack{
						Button(action: {
							self.showLoginSheet = true
						}) {
							VStack {
								Text("Profile")
							}
						}
					}
				}
			}
			.fullScreenCover(isPresented: $showLoginSheet) {
				LoginView(showLoginSheet: $showLoginSheet)
			}
			
			// Show the LoginView as an overlay
//			if showLoginSheet {
//				LoginView(showLoginSheet: $showLoginSheet)
//					.transition(.move(edge: .bottom))
//			}
			// }
		}
	}
}

struct TabContainerView_Previews: PreviewProvider {
    static var previews: some View {
        TabContainerView(imageLoader: .mock, service: .mock, vm: BTTConfigModel())
    }
}
