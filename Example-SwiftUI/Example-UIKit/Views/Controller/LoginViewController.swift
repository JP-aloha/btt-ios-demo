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
    @IBOutlet weak var btnLogin : UIButton!
    @IBOutlet weak var btnLogout : UIButton!
	private var userModel = UserViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadLoginValue()
    }
    
    private func loadLoginValue(){
		if let user = userModel.loggedInUser(){
            txtUserName.text = user.name
            txtPassword.text = user.pass
            txtUserName.isEnabled = false
            txtPassword.isEnabled = false
            btnLogin.isEnabled    = false
            btnLogout.isEnabled   = true
            segment.selectedSegmentIndex = user.isPremium
        }else{
            txtUserName.isEnabled = true
            txtPassword.isEnabled = true
            btnLogin.isEnabled    = true
            btnLogout.isEnabled   = false
        }
    }

    @IBAction func didSelectLogin(_ sender: UIButton) {
        if let name = txtUserName.text, let pass = txtPassword.text{
            userModel.loggedIn(name, pass: pass, isPremium: segment.selectedSegmentIndex)
            BlueTriangle.metrics["name"] = ""
            
            BlueTriangle._setMetrics(name, forKey: "user")
            BlueTriangle._setMetrics((segment.selectedSegmentIndex != 0) ? true : false, forKey: "isPremium")
        }
        self.dismiss(animated: false)

    }
    
    
    @IBAction func didSelectLogout(_ sender: UIButton) {
        userModel.logOut()
        self.dismiss(animated: false)
        BlueTriangle._setMetrics(nil, forKey: "user")
        BlueTriangle._setMetrics(false, forKey: "isPremium")
    }
    
    @IBAction func didSelectCancel(_ sender: UIButton) {
        self.dismiss(animated: false)
    }
}
