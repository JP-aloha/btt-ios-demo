//
//  AuthContainerViewController.swift
//
//  Created by Ashok Singh on 17/12/25.
//  Copyright © 2025 Blue Triangle. All rights reserved.
//

import UIKit

final class AuthContainerViewController: UIViewController {

    private let loginVC = LoginViewController()

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
    }

    // MARK: - UI Setup
    private func setupUI() {
        cancelButton.addTarget(
            self,
            action: #selector(didTapCancel),
            for: .touchUpInside
        )

        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(cancelButton)
        view.addSubview(contentView)

        NSLayoutConstraint.activate([
            // Cancel (top-left)
            cancelButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

            // Content
            contentView.topAnchor.constraint(equalTo: cancelButton.bottomAnchor, constant: 5),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        addChild(loginVC)
        loginVC.view.frame = contentView.bounds
        loginVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.addSubview(loginVC.view)
        loginVC.didMove(toParent: self)
    }

    // MARK: - Actions
    @objc private func didTapCancel() {
        dismiss(animated: true)
    }
}
