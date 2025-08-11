//
//  OrderSuccessfulViewController.swift
//
//  Created by admin on 30/06/23.
//  Copyright © 2023 Blue Triangle. All rights reserved.
//

import UIKit

class OrderCheckOutViewController: UIViewController {

    @IBOutlet weak var lblCheckoutId: UILabel!
    @IBOutlet weak var btnConitueShopping: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    
    var checkoutID: String!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lblCheckoutId.text = checkoutID
        btnSetup()
        navigationItem.title = "Checkout"
        let backButton = UIBarButtonItem()
        backButton.title = "Cart"
        navigationItem.backBarButtonItem = backButton
        btnConitueShopping.accessibilityIdentifier = "continue shopping"
        btnBack.accessibilityIdentifier = "back"
        
        showStep(controller: PaymentConfirmationController(message: "Waiting for payment confirmation..."), delay: 1) {
            self.showStep(controller: OrderConfirmationController(message: "Waiting for order confirmation..."), delay: 1) {
                self.showStep(controller: OrderPlacedController(message: "Order placed successfully..."), delay: 1) {
                    self.finalSetup()
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @IBAction func didSelectBack(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }

    @IBAction func didSelectContiueShopiing(_ sender: UIButton) {
        ANRTest.heavyLoop()
        self.navigationController?.popViewController(animated: true)
    }
    
    func btnSetup() {
        self.btnConitueShopping.layer.cornerRadius = 8
       
    }
    
    func finalSetup() {
        self.lblCheckoutId.text = checkoutID
        self.lblCheckoutId.isHidden = false
        self.btnConitueShopping.isHidden = false
        self.btnBack.isHidden = false
        self.btnSetup()
    }
    
    func showStep(controller: UIViewController, delay: TimeInterval, completion: @escaping () -> Void) {
        addChild(controller)
        controller.view.frame = self.view.bounds
        self.view.addSubview(controller.view)
        controller.didMove(toParent: self)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            controller.willMove(toParent: nil)
            controller.view.removeFromSuperview()
            controller.removeFromParent()
            completion()
        }
    }
}

class ConfirmationLoaderController: UIViewController {
    let message: String
    init(message: String) {
        self.message = message
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMessageView()
    }

    private func setupMessageView() {
        // Container view
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = UIColor.black
        containerView.layer.cornerRadius = 20
        view.addSubview(containerView)

        NSLayoutConstraint.activate([
            containerView.widthAnchor.constraint(equalToConstant: 320),
            containerView.heightAnchor.constraint(equalToConstant: 320),
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        // Label
        let label = UILabel()
        label.text = message
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: containerView.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -16)
        ])
    }
}

class PaymentConfirmationController: ConfirmationLoaderController {}
class OrderConfirmationController: ConfirmationLoaderController {}
class OrderPlacedController: ConfirmationLoaderController {}


