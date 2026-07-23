import UIKit

final class FloatingButton {
    static let shared = FloatingButton()
    private init() {}

    private weak var button: UIButton?
    private var overlayWindow: PassthroughWindow?
    private let popup = FloatingPopupView()

    // MARK: - Public API

    /// Call once to show the floating button.
    func show() {
        // If already present, bring to front
        if let w = overlayWindow, let b = button {
            w.bringSubviewToFront(b)
            return
        }

        guard let scene = activeWindowScene() else { return }

        // Create overlay window
        let window = PassthroughWindow(windowScene: scene)
        window.backgroundColor = .clear
        window.windowLevel = .alert + 1
        window.isHidden = false

        // root view so safe area/rotation works
        let root = UIView(frame: window.bounds)
        root.backgroundColor = .clear
        root.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        window.addSubview(root)

        // Button
        let b = UIButton(type: .custom)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("+", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 28, weight: .bold)
        b.backgroundColor = .systemBlue
        b.layer.cornerRadius = 28
        b.clipsToBounds = true
        b.accessibilityLabel = "Floating"
        b.addTarget(self, action: #selector(tapped), for: .touchUpInside)

        window.addSubview(b)

        NSLayoutConstraint.activate([
            b.widthAnchor.constraint(equalToConstant: 56),
            b.heightAnchor.constraint(equalToConstant: 56),
            b.trailingAnchor.constraint(equalTo: window.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            b.bottomAnchor.constraint(equalTo: window.safeAreaLayoutGuide.bottomAnchor, constant: -100)
        ])

        // Keep references
        self.button = b
        self.overlayWindow = window
        window.floatingButton = b
        window.popupView = popup
    }

    /// Hide and remove the floating button + overlay.
    func hide() {
        button?.removeFromSuperview()
        button = nil
        overlayWindow?.isHidden = true
        overlayWindow = nil
    }

    // MARK: - Actions

    @objc private func tapped() {
        guard let window = overlayWindow else { return }
        // Show popup inside the overlay window so it visually sits on the same layer
        popup.show(in: window)
    }

    // MARK: - Helpers

    private func activeWindowScene() -> UIWindowScene? {
        // prefer the foreground active scene
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first(where: { $0.activationState == .foregroundActive }) ??
            (UIApplication.shared.connectedScenes.first as? UIWindowScene)
    }
}

/// A UIWindow subclass that passes touches through except where the floating button (or other interactive subviews) are.
private class PassthroughWindow: UIWindow {
    // set by FloatingButton after creating the button
    weak var floatingButton: UIView?
    weak var popupView: UIView?

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // If the point hits the floating button (or any interactive subview you want), allow it to receive touches.
        if let btn = floatingButton, !btn.isHidden, btn.alpha > 0.01 {
            let pointInButton = convert(point, to: btn)
            if btn.point(inside: pointInButton, with: event) {
                return super.hitTest(point, with: event)
            }
        }
        
        if let btn = popupView, !btn.isHidden, btn.alpha > 0.01 {
            let pointInButton = convert(point, to: btn)
            if btn.point(inside: pointInButton, with: event) {
                return super.hitTest(point, with: event)
            }
        }
        
        return nil
    }
}

