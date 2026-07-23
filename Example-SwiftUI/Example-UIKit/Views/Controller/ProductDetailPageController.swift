//
//  ProductDetailViewController.swift
//
//  Created by Ashok Singh on 17/12/25.
//  Copyright © 2023 Blue Triangle. All rights reserved.
//

import UIKit

 class ProductDetailPageController: UIPageViewController {

    private var pages: [UIViewController] = []

    init(images: [UIImage]) {
        super.init(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: nil
        )

        self.pages = images.map {
            ProductImagePageViewController(image: $0)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self

        if let first = pages.first {
            setViewControllers([first], direction: .forward, animated: false)
        }
        
        forceLoadForTestingOnly()
    }
     
     internal func forceLoadForTestingOnly() {
         pages.forEach { _ = $0.view }
     }
}

extension ProductDetailPageController: UIPageViewControllerDataSource {

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard
            let index = pages.firstIndex(of: viewController),
            index > 0
        else { return nil }

        return pages[index - 1]
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard
            let index = pages.firstIndex(of: viewController),
            index < pages.count - 1
        else { return nil }

        return pages[index + 1]
    }
}

class ProductImagePageViewController: UIViewController {

    private let imageView = UIImageView()
    private let image: UIImage

    init(image: UIImage) {
        self.image = image
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        print("ProductImagePageViewController")
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .clear

        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true

        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
