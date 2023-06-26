//
//  ProductViewController.swift
//
//  Created by Admin on 21/06/23.
//  Copyright © 2023 Blue Triangle. All rights reserved.
//

import UIKit
import Service
import Combine
class ProductViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    let service = Service.captured
    let imageLoader = ImageLoader.live
    var vm: ProductListViewModel?
    
    @IBOutlet weak var ProductCollectionView: UICollectionView!
 
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backButtonTitle = "Product"
        vm = ProductListViewModel(cartRepository: CartRepository(service: service),
                                  imageLoader: imageLoader,
                                  service: service)
        loadData()
    }
    
    func loadData()  {
        Task {
            let _ =  await vm?.loadProducts()
            self.ProductCollectionView.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        vm?.productList.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell:ProductCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCollectionViewCell", for: indexPath) as! ProductCollectionViewCell
        
        let product = vm?.productList[indexPath.row]
        cell.product = product
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let product = vm?.productList[indexPath.row],
           let vc :ProductDetailView = self.storyboard?.instantiateViewController(withIdentifier: "ProductDetailView") as? ProductDetailView
        {
            vc.vm = ProductDetailViewModel(cartRepository: CartRepository(service: service), imageLoader: imageLoader, product: product)
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
