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
    @IBOutlet weak var logInView : UIView!
    @IBOutlet weak var logOutView : UIView!
    
    @IBOutlet weak var lblUserName : UILabel!
    @IBOutlet weak var lblPremium : UILabel!
    
	private var userModel = UserViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateUI()
    }
    
    private func updateUI(){
		if let user = userModel.loggedInUser(){
            txtUserName.text = user.name
            txtPassword.text = user.pass
            lblUserName.text = user.name
            lblPremium.text = (user.isPremium != 0) ? "Premium" : "Normal"
            segment.selectedSegmentIndex = user.isPremium
            logInView.isHidden    = true
            logOutView.isHidden   = false
            BlueTriangle.setCustomVariable("user", value: user.name)
            BlueTriangle.setCustomVariable("isPremium", value: (user.isPremium != 0) ? true : false)
        }else{
            logInView.isHidden    = false
            logOutView.isHidden   = true
            segment.selectedSegmentIndex = 0
            lblPremium.text = "Normal"
            txtUserName.text = ""
            txtPassword.text = ""
            BlueTriangle.clearCustomVariable("user")
            BlueTriangle.setCustomVariable("isPremium", value: false)
        }
    }

    @IBAction func didSelectLogin(_ sender: UIButton) {
        if let name = txtUserName.text, let pass = txtPassword.text{
            userModel.loggedIn(name, pass: pass, isPremium: segment.selectedSegmentIndex)
            BlueTriangle.setCustomVariable("user", value: name)
            BlueTriangle.setCustomVariable("isPremium", value: (segment.selectedSegmentIndex != 0) ? true : false)
            self.updateUI()
        }
    }
    
    
    @IBAction func didSelectLogout(_ sender: UIButton) {
        userModel.logOut()
        BlueTriangle.clearCustomVariable("user")
        BlueTriangle.setCustomVariable("isPremium", value: false)
        self.updateUI()
    }
    
    @IBAction func didSelectCancel(_ sender: UIButton) {
        self.dismiss(animated: false)
    }
}
