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
    
    private func setupSlideScrollView(slides : [TutorialPageViewController]) {
        scrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        scrollView.contentSize = CGSize(width: view.frame.width * CGFloat(slides.count), height: view.frame.height - 150.0)
        scrollView.isPagingEnabled = true
        
        // set up pages x coordinate and height width
        for i in 0 ..< slides.count {
            slides[i].view.frame = CGRect(x: view.frame.width * CGFloat(i), y: 0, width: view.frame.width, height: view.frame.height)
            scrollView.addSubview(slides[i].view)
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
