//
//  LoginViewController.swift
//
//  Created by Ashok Singh on 08/10/24.
//  Copyright © 2024 Blue Triangle. All rights reserved.
//

import UIKit
import BlueTriangle

class LoginViewController: UIViewController {

    @IBOutlet weak var segment : UISegmentedControl!
    @IBOutlet weak var txtUserName : UITextField!
    @IBOutlet weak var txtPassword : UITextField!
     var userModel : UserViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadLoginValue()
    }
    
    private func loadLoginValue(){
        if let model = userModel, let user = model.loggedInUser(){
            txtUserName.text = user.name
            txtPassword.text = user.pass
            segment.selectedSegmentIndex = user.isPremium
        }
    }

    @IBAction func didSelectLogin(_ sender: UIButton) {
        if let model = userModel, let name = txtUserName.text, let pass = txtPassword.text{
            model.loggedIn(name, pass: pass, isPremium: segment.selectedSegmentIndex)
        }
        self.dismiss(animated: false)
        BlueTriangle.metrics = ["CV1" : "Light"]
    }
    
    
    @IBAction func didSelectLogout(_ sender: UIButton) {
        if let model = userModel{
            model.logOut()
        }
        self.dismiss(animated: false)
        BlueTriangle.metrics = ["CV1" : nil]
    }
    
    @IBAction func didSelectCancel(_ sender: UIButton) {
        self.dismiss(animated: false)
    }
}
