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
    private lazy var prevButton = UIBarButtonItem(title: "Prev",
                                                  style: .plain,
                                                  target: self,
                                                  action: #selector(prevTapped))
    private lazy var nextButton = UIBarButtonItem(title: "Next",
                                                  style: .plain,
                                                  target: self,
                                                  action: #selector(nextTapped))
    private lazy var skipOrDoneButton = UIBarButtonItem(title: "Skip",
                                                        style: .done,
                                                        target: self,
                                                        action: #selector(skipButtonTapped))

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Tutorial"
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadSlidePages()

        // Nav buttons: Prev | (Next, Skip/Done)
        navigationItem.leftBarButtonItem = prevButton
        navigationItem.rightBarButtonItems = [nextButton, skipOrDoneButton]
        prevButton.accessibilityIdentifier = "intro prev"
        skipOrDoneButton.accessibilityIdentifier = "intro skip"
        nextButton.accessibilityIdentifier = "intro next"

        updateNavButtons()
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
            vc.view.translatesAutoresizingMaskIntoConstraints = false
            vc.view.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        }
    }

    // MARK: - Button actions

    @objc private func prevTapped() {
        goToPage(pageControl.currentPage - 1, animated: true)
    }

    @objc private func nextTapped() {
        if pageControl.currentPage == (slides.count - 1) {
            // Last page → act like Done
            skipButtonTapped()
        } else {
            goToPage(pageControl.currentPage + 1, animated: true)
        }
    }

    private func goToPage(_ index: Int, animated: Bool) {
        guard slides.indices.contains(index) else { return }
        let x = CGFloat(index) * scrollView.bounds.width
        scrollView.setContentOffset(CGPoint(x: x, y: 0), animated: animated)
        pageControl.currentPage = index
        updateNavButtons()
    }

    private func updateNavButtons() {
        let idx = pageControl.currentPage
        let last = slides.count - 1

        prevButton.isEnabled = idx > 0
        nextButton.isEnabled = idx < last
        skipOrDoneButton.title = (idx == last) ? "Done" : "Skip"
        skipOrDoneButton.accessibilityIdentifier = (idx == last) ? "intro done" : "intro skip"
    }

    @objc private func skipButtonTapped() {
        dismiss(animated: true, completion: nil)

        let isTutorial = UserDefaults.standard.bool(forKey: UserDefaultKeys.TutorialShownKey)
        if !isTutorial {
            UserDefaults.standard.set(true, forKey: UserDefaultKeys.TutorialShownKey)
            UserDefaults.standard.synchronize()
            AppCoordinator.setupRootTabVc()
        }
    }
}

extension TutorialViewController : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = Int(round(scrollView.contentOffset.x / max(1, scrollView.bounds.width)))
        if pageControl.currentPage != pageIndex, slides.indices.contains(pageIndex) {
            pageControl.currentPage = pageIndex
            updateNavButtons()
        }
    }
}
