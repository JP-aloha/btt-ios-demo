//
//  CartViewController.swift
//
//  Created by Admin on 22/06/23.
//  Copyright © 2023 Blue Triangle. All rights reserved.
//

import UIKit
import Combine
import Service
import BlueTriangle

class CartViewController: UIViewController {

    @IBOutlet weak var tableStackView: UIStackView!
    @IBOutlet weak var emptyCartView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnCheckOut: UIButton!
    
    @IBOutlet weak var lblSubtotal: UILabel!
    @IBOutlet weak var lblTax: UILabel!
    private let service = Service.captured
     var vm: CartViewModel!
    private var cancellable: Set<AnyCancellable> = []
    private var timer : BTTimer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnSetup()
        getCart()
        resisterObserver()
        btnCheckOut.accessibilityIdentifier = "checkout"
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let isScreenTracking : Bool = UserDefaults.standard.bool(forKey: ConfigUserDefaultKeys.ConfigScreenTrackingKey)
        if !isScreenTracking, BlueTriangle.initialized{
            self.timer = BlueTriangle.startTimer(
                page: Page(
                    pageName: "CartViewController Mannual Tracking"))
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let isScreenTracking : Bool = UserDefaults.standard.bool(forKey: ConfigUserDefaultKeys.ConfigScreenTrackingKey)
        if let timer = self.timer, !isScreenTracking, BlueTriangle.initialized{
            BlueTriangle.endTimer(timer)
        }
    }
    
    func getCart() {
        vm.$productItems.sink(receiveValue: { [weak self] _ in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.setupTotals()
            }
        }).store(in: &cancellable)
    }
    
    @IBAction func didSelectUserInfo(_ sender: UIButton) {
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		if let loginVc = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController {
			loginVc.modalPresentationStyle = .fullScreen
			self.present(loginVc, animated: true)
		}
    }
    
    @IBAction func btnActionCheckOut(_ sender: UIButton) {
        if vm.productItems.count > 4 {
            ANRTest.cartLimitExceedCrash()
        } else if vm.productItems.isEmpty {
            ANRTest.emptyCartCrash()
        }
        
        Task {
            await vm.checkout()
            await vm.placeOrder()
            
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "OrderSuccessfulViewController") as? OrderSuccessfulViewController{
                vc.checkoutID = vm.checkoutItem?.confirmation ?? UUID().uuidString
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
//            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "CheckOutViewController") as? CheckOutViewController,
//               let checkout = vm.checkoutItem {
//                vc.vm = vm.checkoutViewModel(checkout)
//                vc.delegate = self
//                self.present(vc, animated: true)
//            }
        }
    }
    
    func initXib(){
        tableView.register(UINib(nibName: "CartItemTableViewCell", bundle: nil),forCellReuseIdentifier: "CartItemTableViewCell")
    }
    
    func btnSetup(){
        self.btnCheckOut.layer.cornerRadius = 8
       
    }

    func setupTotals() {
        self.lblTax.text = "$\(vm.estimatedTax.roundedToPlaces())"
        self.lblSubtotal.text = "$\(vm.subtotal.roundedToPlaces())"
    }
    
     //MARK: - Memory Warning observers
    
    @objc func raiseMemoryWarning(){
        let alert = UIAlertController(title: "Error", message: "Detected memory warning. ", preferredStyle: UIAlertController.Style.alert)
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

extension CartViewController: UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        emptyCartView.isHidden =  !vm.productItems.isEmpty
//        tableStackView.isHidden = vm.productItems.isEmpty
        return vm.productItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "CartItemTableViewCell") as? CartItemTableViewCell {
            cell.initCell(with: vm.productItems[indexPath.row], index: indexPath.row)
            cell.delegate = self
            return cell
        }
       return UITableViewCell()
    }
    
}

extension CartViewController: CartItemTVCDelegate {
    func chageQuanitiy(to quantity: Int, for index: Int) {
        if quantity > vm.productItems[index].quantity {
            Task {
                let id = self.vm.productItems[index].id
                self.view.isUserInteractionEnabled = false
                await vm.increment(id: id)
                self.tableView.reloadData()
                self.view.isUserInteractionEnabled = true
            }
        } else {
            Task {
                let id = self.vm.productItems[index].id
                self.view.isUserInteractionEnabled = false
                await vm.decrement(id: id)
                self.tableView.reloadData()
                self.view.isUserInteractionEnabled = true
            }
        }
        if self.vm.productItems.isEmpty {
            ANRTest.emptyCartCrash()
        }
    }
    
    func deleteItem(at index: Int) {
        
        ANRTest.removeCartItem()
        if vm.productItems.count > index {
            Task {
                self.view.isUserInteractionEnabled = false
                let id = self.vm.productItems[index].id
                await vm.removeProduct(id: id)
                self.tableView.reloadData()
                self.view.isUserInteractionEnabled = true
            }
        }
    }
}

extension CartViewController: CheckoutVCDelegate {
    func didCheckout(with id: String) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "OrderSuccessfulViewController") as? OrderSuccessfulViewController{
            vc.checkoutID = id
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
