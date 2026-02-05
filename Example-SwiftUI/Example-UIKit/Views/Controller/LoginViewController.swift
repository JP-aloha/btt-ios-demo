//
//  LoginViewController.swift
//
//  Created by Ashok Singh on 08/10/24.
//  Copyright © 2024 Blue Triangle. All rights reserved.
//

import UIKit
import BlueTriangle

final class LoginViewController: UIViewController {

    // MARK: - UI Components
    private let titleLabel = UILabel()
    private let segment = UISegmentedControl(items: ["Normal", "Premium"])
    private let txtUserName = UITextField()
    private let txtPassword = UITextField()
    private let loginButton = UIButton(type: .system)
    private let loginStack = UIStackView()

    // Logout UI
    private let logoutStack = UIStackView()
    private let lblUserName = UILabel()
    private let lblPremium = UILabel()
    private let logoutButton = UIButton(type: .system)

    // MARK: - Data
    private var userModel = UserViewModel()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        updateUI()
    }

    // MARK: - UI Setup
    private func setupUI() {

        // MARK: Login UI
        titleLabel.text = "Login"
        titleLabel.font = .systemFont(ofSize: 26, weight: .bold)
        titleLabel.textAlignment = .center

        segment.selectedSegmentIndex = 0

        styleTextField(txtUserName, placeholder: "Username")
        styleTextField(txtPassword, placeholder: "Password")
        txtPassword.isSecureTextEntry = true
        txtUserName.accessibilityIdentifier = "fld_user_name"
        txtPassword.accessibilityIdentifier = "fld_password"

        loginButton.setTitle("Login", for: .normal)
        loginButton.backgroundColor = .systemBlue
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.layer.cornerRadius = 8
        loginButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        loginButton.addTarget(self, action: #selector(didSelectLogin), for: .touchUpInside)
        loginButton.accessibilityIdentifier = "btn_login"

        loginStack.axis = .vertical
        loginStack.spacing = 16
        loginStack.translatesAutoresizingMaskIntoConstraints = false
        loginStack.addArrangedSubview(titleLabel)
        loginStack.addArrangedSubview(segment)
        loginStack.addArrangedSubview(txtUserName)
        loginStack.addArrangedSubview(txtPassword)
        loginStack.addArrangedSubview(loginButton)

        view.addSubview(loginStack)

        NSLayoutConstraint.activate([
            loginStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loginStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            loginStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])

        // MARK: Logout UI
        setupLogoutUI()
    }

    private func setupLogoutUI() {
        lblUserName.font = .systemFont(ofSize: 20, weight: .semibold)
        lblUserName.textAlignment = .center

        lblPremium.font = .systemFont(ofSize: 16)
        lblPremium.textColor = .secondaryLabel
        lblPremium.textAlignment = .center

        logoutButton.setTitle("Logout", for: .normal)
        logoutButton.backgroundColor = .systemRed
        logoutButton.setTitleColor(.white, for: .normal)
        logoutButton.layer.cornerRadius = 8
        logoutButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        logoutButton.addTarget(self, action: #selector(didSelectLogout), for: .touchUpInside)

        logoutStack.axis = .vertical
        logoutStack.spacing = 16
        logoutStack.alignment = .fill
        logoutStack.translatesAutoresizingMaskIntoConstraints = false

        logoutStack.addArrangedSubview(lblUserName)
        logoutStack.addArrangedSubview(lblPremium)
        logoutStack.addArrangedSubview(logoutButton)

        view.addSubview(logoutStack)

        NSLayoutConstraint.activate([
            logoutStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            logoutStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            logoutStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
    }

    // MARK: - Styling
    private func styleTextField(_ textField: UITextField, placeholder: String) {
        textField.placeholder = placeholder
        textField.borderStyle = .roundedRect
        textField.heightAnchor.constraint(equalToConstant: 44).isActive = true
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
    }

    // MARK: - UI State (Equivalent to your old logic)
    private func updateUI() {

        if let user = userModel.loggedInUser() {
            // Logged in
            txtUserName.text = user.name
            txtPassword.text = user.pass

            lblUserName.text = "Welcome, \(user.name)"
            lblPremium.text = user.isPremium != 0 ? "Premium User" : "Normal User"
            segment.selectedSegmentIndex = user.isPremium

            loginStack.isHidden = true
            logoutStack.isHidden = false

            BlueTriangle.setCustomVariable("CV1", value: user.name)
            BlueTriangle.setCustomVariable("CV2", value: user.isPremium != 0)
            if user.isPremium != 0 {
                BlueTriangle.setCustomCategory1("Premium")
            } else {
                BlueTriangle.setCustomCategory1("Standard")
            }

        } else {
            // Logged out
            loginStack.isHidden = false
            logoutStack.isHidden = true

            segment.selectedSegmentIndex = 0
            lblPremium.text = "Normal User"
            txtUserName.text = ""
            txtPassword.text = ""

            BlueTriangle.clearCustomVariable("CV1")
            BlueTriangle.clearCustomVariable("CV2")
            BlueTriangle.setCustomCategory1("Standard")

        }
    }

    // MARK: - Actions
    @objc private func didSelectLogin() {
        guard
            let name = txtUserName.text,
            let pass = txtPassword.text
        else { return }

        userModel.loggedIn(name, pass: pass, isPremium: segment.selectedSegmentIndex)
        updateUI()
    }

    @objc private func didSelectLogout() {
        userModel.logOut()
        updateUI()
    }
}
