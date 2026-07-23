//
//  ProductListViewModel.swift
//
//  Created by Mathew Gacy on 10/27/22.
//  Copyright © 2022 Blue Triangle. All rights reserved.
//

import BlueTriangle
import Foundation
import Service

final class ProductListViewModel: ObservableObject {
    @Published private(set) var products: ([Product], [Product]) = ([], [])
    @Published private(set) var productList: [Product] = []
    @Published var error: Error?
    private let cartRepository: CartRepository
    private let imageLoader: ImageLoader
    private let service: Service
    private var hasAppeared: Bool = false
    private(set) var configureSessionId : String = UserDefaults.standard.string(forKey: UserDefaultKeys.ConfigureSessionId) ?? "Auto Generated"

    init(
        cartRepository: CartRepository,
        imageLoader: ImageLoader,
        service: Service
    ) {
        self.cartRepository = cartRepository
        self.imageLoader = imageLoader
        self.service = service
    }

    @MainActor
    func loadProducts() async {
        // Custom metrics
        // BlueTriangle.metrics?["metrics-page"] = "product-list"

        NSLog("SessionID : %@", configureSessionId)
        
        var timer : BTTimer?
        
        if BlueTriangle.initialized {
            // Start timer
           /* timer = BlueTriangle.startTimer(
                page: Page(
                    pageName: "ProductList"))*/
        }

        do {
            let productResponse = try await service.products()

            products = productResponse.splitTuple()
            productList = productResponse
            let imageURLS = productResponse.map { product in
                   return product.image
              }
            
            try await imageLoader.fetch(urls: imageURLS)
            
        } catch {
            self.error = error
        }
       
        if BlueTriangle.initialized, let timer = timer {
            // End timer after view images have loaded
          //  BlueTriangle.endTimer(timer)
        }
    }

    func onAppear() async {
        guard !hasAppeared else {
            return
        }

        defer {
            hasAppeared = true
        }
        await loadProducts()
    }

    func imageStatus(_ url: URL) async -> ImageStatus? {
        await imageLoader.images[url]
    }

    func detailViewModel(for productID: Product.ID) -> ProductDetailViewModel? {
        guard let product = products.0.first(where: { $0.id == productID }) ?? products.1.first(where: { $0.id == productID }) else {
            return nil
        }

        return ProductDetailViewModel(
            cartRepository: cartRepository,
            imageLoader: imageLoader,
            product: product)
    }
}
