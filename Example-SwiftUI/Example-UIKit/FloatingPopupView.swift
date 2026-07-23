//
//  FloatingPopupView.swift
//
//  Created by Ashok Singh on 18/09/25.
//  Copyright © 2025 Blue Triangle. All rights reserved.
//
import UIKit

class FloatingPopupView: UIView {

    private let contentView = UIView()
    private let closeButton = UIButton(type: .system)
    private let anrButton = UIButton(type: .system)
    private let crashButton = UIButton(type: .system)

    // MARK: - Init
    init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setup() {
        backgroundColor = UIColor.black.withAlphaComponent(0.45)

        // contentView
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = .systemBackground
        contentView.layer.cornerRadius = 12
        contentView.clipsToBounds = true
        addSubview(contentView)

        NSLayoutConstraint.activate([
            contentView.centerXAnchor.constraint(equalTo: centerXAnchor),
            contentView.centerYAnchor.constraint(equalTo: centerYAnchor),
            contentView.widthAnchor.constraint(equalToConstant: 300),
            contentView.heightAnchor.constraint(equalToConstant: 220)
        ])

        // Label and buttons stacked vertically
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Blue Triangle feature"
        label.textAlignment = .center
        label.numberOfLines = 2

        anrButton.translatesAutoresizingMaskIntoConstraints = false
        anrButton.setTitle("ANR", for: .normal)
        anrButton.addTarget(self, action: #selector(anrTapped), for: .touchUpInside)

        crashButton.translatesAutoresizingMaskIntoConstraints = false
        crashButton.setTitle("Crash", for: .normal)
        crashButton.addTarget(self, action: #selector(crashTapped), for: .touchUpInside)

        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setTitle("Close", for: .normal)
        closeButton.addTarget(self, action: #selector(dismissTapped), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [label, anrButton, crashButton, closeButton])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .center
        contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -12)
        ])

        [anrButton, crashButton, closeButton].forEach { btn in
            btn.contentEdgeInsets = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)
            btn.widthAnchor.constraint(equalTo: stack.widthAnchor).isActive = true
        }

        // Tap to dismiss when tapping outside contentView
        let tap = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped(_:)))
        tap.cancelsTouchesInView = false
        addGestureRecognizer(tap)

        // initial animation state
        alpha = 0
        contentView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
    }

    // MARK: - Show / Dismiss (window-based, no view controller)

    /// Show by adding into a window (recommended: the overlay window).
    func show(in window: UIWindow) {
        frame = window.bounds
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        window.addSubview(self)
        window.bringSubviewToFront(self)
        animateIn()
    }

    private func animateIn() {
        UIView.animate(withDuration: 0.22, delay: 0, options: [.curveEaseOut]) {
            self.alpha = 1
            self.contentView.transform = .identity
        }
    }

    @objc func dismiss() {
        UIView.animate(withDuration: 0.18, delay: 0, options: [.curveEaseIn], animations: {
            self.alpha = 0
            self.contentView.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
        }, completion: { _ in
            self.removeFromSuperview()
        })
    }

    // MARK: - Actions

    @objc private func backgroundTapped(_ g: UITapGestureRecognizer) {
        // dismiss only if tap is outside contentView
        let pt = g.location(in: contentView)
        if !contentView.bounds.contains(pt) { dismiss() }
    }

    @objc private func dismissTapped() { dismiss() }

    @objc private func anrTapped() {
        // call your ANR logic
        ANRTest.removeCartItem()
        dismiss()
    }

    @objc private func crashTapped() {
        // call your crash logic
        ANRTest.emptyCartCrash()
        dismiss()
    }
}
