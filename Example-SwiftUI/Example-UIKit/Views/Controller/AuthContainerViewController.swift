//
//  AuthContainerViewController.swift
//
//  Created by Ashok Singh on 17/12/25.
//  Copyright © 2025 Blue Triangle. All rights reserved.
//

import UIKit

final class AuthContainerViewController: UIViewController {

    enum Child: Int {
        case login = 0
        case signup = 1
    }

    private var currentChild: UIViewController?

    // MARK: - Cached Child VCs
    private var loginVC: LoginViewController = {
        let vc = LoginViewController()
        return vc
    }()

    private var signupVC: SignupViewController = {
        let vc = SignupViewController()
        return vc
    }()

    // MARK: - UI
    private let segmentControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Login", "Signup"])
        sc.selectedSegmentIndex = 0
        return sc
    }()

    private let cancelButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Cancel", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        return btn
    }()

    private let contentView = UIView()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()

        // Initial screen
        switchToChild(signupVC)
        switchToChild(loginVC)
    }

    // MARK: - UI Setup
    private func setupUI() {
        segmentControl.addTarget(
            self,
            action: #selector(segmentChanged),
            for: .valueChanged
        )

        cancelButton.addTarget(
            self,
            action: #selector(didTapCancel),
            for: .touchUpInside
        )

        segmentControl.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(segmentControl)
        view.addSubview(cancelButton)
        view.addSubview(contentView)

        NSLayoutConstraint.activate([
            // Cancel (top-right)
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            cancelButton.centerYAnchor.constraint(equalTo: segmentControl.centerYAnchor),

            // Segment (top-center)
            segmentControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            segmentControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            // Content
            contentView.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 5),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - Actions
    @objc private func segmentChanged() {
        guard let child = Child(rawValue: segmentControl.selectedSegmentIndex) else { return }

        switch child {
        case .login:
            switchToChild(loginVC)
        case .signup:
            switchToChild(signupVC)
        }
    }

    @objc private func didTapCancel() {
        dismiss(animated: true)
    }

    // MARK: - Child Containment
    private func switchToChild(_ newVC: UIViewController) {
        if currentChild === newVC { return }

        if let current = currentChild {
            current.willMove(toParent: nil)
            current.view.removeFromSuperview()
            current.removeFromParent()
        }

        addChild(newVC)
        newVC.view.frame = contentView.bounds
        newVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.addSubview(newVC.view)
        newVC.didMove(toParent: self)

        currentChild = newVC
    }
}
