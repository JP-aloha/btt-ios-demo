//
//  TabBarViewController.swift
//
//  Created by admin on 27/06/23.
//  Copyright © 2023 Blue Triangle. All rights reserved.
//

import UIKit
import SwiftUI
import Service

class TabBarViewController: UITabBarController {

    let service = Service.captured
    let imageLoader = ImageLoader.live
    var cartRepository: CartRepository!
    override func viewDidLoad() {
        super.viewDidLoad()
        cartRepository = CartRepository(service: service)
        if let navVC = self.viewControllers?[0] as? UINavigationController, let productListVC = navVC.viewControllers[0] as? ProductViewController {
            productListVC.vm = ProductListViewModel(cartRepository: cartRepository, imageLoader: imageLoader, service: service)
        }

        if let navVC = self.viewControllers?[1] as? UINavigationController, let cartVC =  navVC.viewControllers[0] as? CartViewController {
            cartVC.vm = CartViewModel(service: service, cartRepository: cartRepository)
        }

        // Insert as the 3rd tab (after Products, Cart), matching the SwiftUI
        // target's tab order, rather than appending after Settings.
        var updatedViewControllers = viewControllers ?? []
        let matricKitIndex = min(2, updatedViewControllers.count)
        updatedViewControllers.insert(makeMatricKitTab(), at: matricKitIndex)

        // User tab goes right after MatricKit, before Settings — same
        // Products/Cart/MatricKit/User/Settings order as the SwiftUI target.
        let userIndex = min(matricKitIndex + 1, updatedViewControllers.count)
        updatedViewControllers.insert(makeUserTab(), at: userIndex)

        viewControllers = updatedViewControllers
    }

    /// Hosts the same SwiftUI MatricKit feature (Dashboard/Metrics/Diagnostics/Triggers)
    /// used by the SwiftUI demo target, wrapped in its own NavigationStack since
    /// there's no shared UIKit navigation controller to push onto here.
    private func makeMatricKitTab() -> UIViewController {
        let host = UIHostingController(
            rootView: NavigationStack { MatricKitView() }
                .environmentObject(MetricKitManager.shared)
                .environmentObject(HitchRateMonitor.shared)
        )
        host.tabBarItem = UITabBarItem(
            title: "MatricKit",
            image: UIImage(systemName: "gauge.with.dots.needle.67percent"),
            selectedImage: nil
        )
        return host
    }

    /// Fully native UIKit User tab — a plain table (Profile/Order
    /// History/Favourite) inside its own UINavigationController, unlike
    /// MatricKit above which hosts SwiftUI.
    private func makeUserTab() -> UIViewController {
        let nav = UINavigationController(rootViewController: UserTableViewController())
        nav.tabBarItem = UITabBarItem(
            title: "User",
            image: UIImage(systemName: "person.crop.circle"),
            selectedImage: nil
        )
        return nav
    }
}
