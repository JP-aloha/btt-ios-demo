//
//  ProductListView.swift
//
//  Created by Mathew Gacy on 10/27/22.
//  Copyright © 2022 Blue Triangle. All rights reserved.
//

import Service
import SwiftUI
import BlueTriangle

struct ProductListView: View {
    enum Route: Hashable {
        case productDetail(Product)
    }

    @ObservedObject var viewModel: ProductListViewModel
    @State var  timer : BTTimer?
    @State private var sessionID = ""

    var columns: [GridItem] {
        [GridItem(.adaptive(minimum: 150, maximum: 170))]
    }

    var body: some View {
        VStack {
            VStack{
                ScrollView {
                    HStack(alignment: .top, spacing: 16) {
                        LazyVGrid(columns: columns) {
                            ForEach(viewModel.products.0) { product in
                                NavigationLink(value: product) {
                                    ProductCell(
                                        imageStatusProvider: viewModel.imageStatus(_:),
                                        product: product)
                                    .bttTrackAction("Tap ProductCell \(product.name)")
                                }
                            }
                        }
                        
                        LazyVGrid(columns: columns) {
                            ForEach(viewModel.products.1) { product in
                                NavigationLink(value: product) {
                                    ProductCell(
                                        imageStatusProvider: viewModel.imageStatus(_:),
                                        product: product)
                                    .bttTrackAction("Tap ProductCell \(product.name)")
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .bttTrackScreen("ProductListView")
                .onAppear{
                    let isScreenTracking : Bool = UserDefaults.standard.bool(forKey: ConfigUserDefaultKeys.ConfigScreenTrackingKey)
                    if !isScreenTracking, BlueTriangle.initialized{
                        self.timer = BlueTriangle.startTimer(
                            page: Page(
                                pageName: "ProductListView Mannual Tracking"))
                    }
                    ConfigurationSetup.updateChangedSassionId()
                    if let sessionId = ConfigurationSetup.getSessionId() {
                        sessionID = sessionId
                    }
                    BlueTriangle.setCustomCategory1("Guest")
                }
                .onDisappear {
                    let isScreenTracking : Bool = UserDefaults.standard.bool(forKey: ConfigUserDefaultKeys.ConfigScreenTrackingKey)
                    if let timer = self.timer, !isScreenTracking, BlueTriangle.initialized{
                        BlueTriangle.endTimer(timer)
                    }
                }
                .refreshable {
                    await viewModel.loadProducts()
                }
                .task {
                    await viewModel.onAppear()
                }
                                
                HStack{
                    Text("SessionID :")
                        .font(Font.system(size: 16, weight: .medium))
                    Text("\(sessionID)")
                        .font(Font.system(size: 16, weight: .regular))
                        .accessibilityIdentifier("sessionid")
                }
                .padding(.bottom, 10)
                .frame(height: 20)
            }
        }
        .errorAlert(error: $viewModel.error)
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)  {
                ConfigurationSetup.updateChangedSassionId()
                if let sessionId = ConfigurationSetup.getSessionId() {
                    sessionID = sessionId
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)  {
                ConfigurationSetup.updateChangedSassionId()
                if let sessionId = ConfigurationSetup.getSessionId() {
                    sessionID = sessionId
                }
            }
        }
    }
}

struct ProductListView_Previews: PreviewProvider {
    static var previews: some View {
        ProductListView(
            viewModel: .init(
                cartRepository: CartRepository(service: .captured),
                imageLoader: .live,
                service: .captured))
    }
}
