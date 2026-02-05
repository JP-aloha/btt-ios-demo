import UIKit
import BlueTriangle

final class SignupViewController: UIViewController {

    // MARK: - UI Components
    private let titleLabel = UILabel()
    private let txtUserName = UITextField()
    private let txtPassword = UITextField()
    private let signupButton = UIButton(type: .system)

    // MARK: - Data
    private var userModel = UserViewModel()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
    }

    // MARK: - UI Setup
    private func setupUI() {

        // Title
        titleLabel.text = "Signup"
        titleLabel.font = .systemFont(ofSize: 26, weight: .bold)
        titleLabel.textAlignment = .center

        // Username
        txtUserName.placeholder = "Username"
        styleTextField(txtUserName)

        // Password
        txtPassword.placeholder = "Password"
        txtPassword.isSecureTextEntry = true
        styleTextField(txtPassword)
        txtUserName.accessibilityIdentifier = "fld_user_name"
        txtPassword.accessibilityIdentifier = "fld_password"

        // Button
        signupButton.setTitle("Signup", for: .normal)
        signupButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        signupButton.backgroundColor = .systemBlue
        signupButton.setTitleColor(.white, for: .normal)
        signupButton.layer.cornerRadius = 8
        signupButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        signupButton.addTarget(self, action: #selector(didSelectSignup), for: .touchUpInside)
        signupButton.accessibilityIdentifier = "btn_signup"
        // Stack
        let stack = UIStackView(arrangedSubviews: [
            titleLabel,
            txtUserName,
            txtPassword,
            signupButton
        ])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
    }

    // MARK: - Styling
    private func styleTextField(_ textField: UITextField) {
        textField.borderStyle = .roundedRect
        textField.heightAnchor.constraint(equalToConstant: 44).isActive = true
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
    }

    // MARK: - Actions
    @objc private func didSelectSignup() {
        guard
            let name = txtUserName.text,
            let pass = txtPassword.text
        else { return }

        userModel.loggedIn(name, pass: pass, isPremium: 0)
    }
}
