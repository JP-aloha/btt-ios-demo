//
//  OrderSuccessfulViewController.swift
//
//  Created by admin on 30/06/23.
//  Copyright © 2023 Blue Triangle. All rights reserved.
//

import UIKit

class OrderSuccessfulViewController: UIViewController {

    @IBOutlet weak var lblCheckoutId: UILabel!
    @IBOutlet weak var btnConitueShopping: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    
    var checkoutID: String!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lblCheckoutId.text = checkoutID
        btnSetup()
        
        let backButton = UIBarButtonItem()
        backButton.title = "Cart"
        navigationItem.backBarButtonItem = backButton
        btnConitueShopping.accessibilityIdentifier = "continue shopping"
        btnBack.accessibilityIdentifier = "back"
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

}
