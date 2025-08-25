//
//  ProductDetailView.swift
//
//  Created by Admin on 21/06/23.
//  Copyright © 2023 Blue Triangle. All rights reserved.
//

import UIKit

class ProductDetailViewController: UIViewController {
     
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productTitle: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var productQty: UILabel!
    @IBOutlet weak var productDesc: UILabel!
    @IBOutlet weak var btnAddtoCart: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var lblQty: UILabel!
    
    var vm: ProductDetailViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBtn()
        setupLbl()
        resisterObserver()
        ConfigurationSetup.configOnOtherScreen()
        let backButton = UIBarButtonItem()
        backButton.title = "Products"
        self.navigationItem.backBarButtonItem = backButton
        self.navigationItem.title = "Product Details"
        btnAddtoCart.accessibilityIdentifier = "add to cart"
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
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        vm.freeAllMemoryOnDisapear()
    }
    
    @IBAction func didSelectBack(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func didClickStepper(_ sender: UIStepper) {
        self.vm.quantity = Int(sender.value)
        self.lblQty.text = "\(vm.quantity)"
    }
    
    private func setupLbl(){
        self.productTitle.text = vm.name
        self.productPrice.text = vm.price
        self.productDesc.text = vm.description
        Task {
            let imageStaus = await vm.imageStatus()
            switch imageStaus {
            case .downloaded(let result):
                switch result {
                case .success(let image):
                    self.productImage.image = image
                default:
                    self.productImage.image = UIImage(systemName: "exclamationmark.circle")
                }
            default:
                self.productImage.image = UIImage(systemName: "exclamationmark.circle")
            }
        }
    }
    
    private func setupBtn() {
        // AddToCart Button
        self.btnAddtoCart.layer.cornerRadius = 8
    }
    
    @IBAction func didSelectAddToCart(_ sender: Any) {
        vm.quantity += 1
        if vm.hasCrashLimitExceed() {
                ANRTest.quantityLimitExceedCrash()
        }
        
        Task {
            btnAddtoCart.isEnabled = false
            await vm.addToCart()
            btnAddtoCart.isEnabled = true
        }
    }
    
    @IBAction func didSelectMemoryWarningScenario(_ sender: Any) {
        let alert = UIAlertController(title: "Memory Warning scenario", message: "You can generate a memory warning by clicking the Add to Cart button continuously after selecting any perfume product, until an alert appears.", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func didSelectCPUScenario(_ sender: Any) {
        let alert = UIAlertController(title: "CPU Usage scenario", message: "You can generate high CPU usage by clicking the Add to Cart button after selecting the product ‘KEY Holder,’ which will increase CPU usage up to 50–80%. Similarly, selecting the product ‘Infinix Inbook’ will increase CPU usage up to 50%", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
     //MARK: - Memory Warning observers
    
    @objc func raiseMemoryWarning(){
        let alert = UIAlertController(title: "Memory Warning", message: "Memory warning received. Your app is using too much memory than expected.", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
     
     private func resisterObserver(){
         
         NotificationCenter.default.addObserver(self,
                                                selector: #selector(raiseMemoryWarning),
                                                name: UIApplication.didReceiveMemoryWarningNotification,
                                                object: nil)
     }
     
     private func removeObserver(){
         NotificationCenter.default.removeObserver(self,
                                                           name: UIApplication.didReceiveMemoryWarningNotification,
                                                           object: nil)
     }
     
     deinit {
         removeObserver()
     }
}
