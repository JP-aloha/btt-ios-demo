//
//  TutorialViewController.swift
//
//  Created by Ashok Singh on 07/08/25.
//  Copyright © 2025 Blue Triangle. All rights reserved.
//

import UIKit
import BlueTriangle

class TutorialViewController: UIViewController {
    @IBOutlet weak var scrollView : UIScrollView!
    @IBOutlet weak var pageControl : UIPageControl!
    private var slides:[TutorialPageViewController] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Tutorial"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.loadSlidePages()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done",
                                                                 style: .done,
                                                                 target: self,
                                                                 action: #selector(doneButtonTapped))
    }
    
    private func loadSlidePages() {
        slides = TutorialPageViewController.getPageSlides()
        setupSlideScrollView(slides: slides)
        scrollView.delegate = self
        pageControl.numberOfPages = slides.count
        pageControl.currentPage = 0
    }
    
    private func setupSlideScrollView(slides: [TutorialPageViewController]) {
        let contentStack = UIStackView()
        contentStack.axis = .horizontal
        contentStack.distribution = .fillEqually
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentStack.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])

        for vc in slides {
            addChild(vc)
            contentStack.addArrangedSubview(vc.view)
            vc.didMove(toParent: self)
            vc.view.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        }
    }
    
    @objc private func doneButtonTapped() {
        self.dismiss(animated: true, completion: nil)
        UserDefaults.standard.set(true, forKey: UserDefaultKeys.TutorialShownKey)
        UserDefaults.standard.synchronize()
        AppCoordinator.setupRootTabVc()
    }
}

extension TutorialViewController : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x/view.frame.width)
        pageControl.currentPage = Int(pageIndex)
    }
}
