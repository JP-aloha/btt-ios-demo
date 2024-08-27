//
//  CartItemTableViewCell.swift
//
//  Created by Admin on 26/06/23.
//  Copyright © 2023 Blue Triangle. All rights reserved.
//

import UIKit

protocol CartItemTVCDelegate: AnyObject {
    func chageQuanitiy(to quantity: Int, for index: Int)
    func deleteItem(at index: Int)
}

class CartItemTableViewCell: UITableViewCell {
    
    @IBOutlet weak var productImg: UIImageView!
    @IBOutlet weak var productTitle: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var productQty: UILabel!    
    @IBOutlet weak var counter: UIStepper!
    @IBOutlet weak var btnRemove: UIButton!
    
    weak var delegate: CartItemTVCDelegate?
    
    private var index: Int?
    
    @IBAction func didClickStepper(_ sender: UIStepper) {
        guard let index = index else { return }
        delegate?.chageQuanitiy(to: Int(sender.value), for: index)
        self.productQty.text = "\(Int(sender.value))"
    }
    
    
    @IBAction func didSelectRemoveItem(_ sender: UIButton) {
        guard let index = index else { return }
        delegate?.deleteItem(at: index)
    }
    
    
    func initCell(with data: CartItemModel, index: Int) {
        self.index = index
        counter.value = Double(data.quantity)
        self.productTitle.text = data.product.name
        self.productQty.text = "\(data.quantity)"
        self.productPrice.text = "$\(data.price.roundedToPlaces())"
        self.btnRemove.accessibilityIdentifier = "btn_remove"
        DispatchQueue.global().async {
            do {
                let data = try Data(contentsOf: data.product.image)
                DispatchQueue.main.async {
                    self.productImg.image = UIImage(data: data)
                }
            } catch {
                print(error)
            }
        }
    }
    
}
