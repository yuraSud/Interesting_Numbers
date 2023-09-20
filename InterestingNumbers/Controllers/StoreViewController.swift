//
//  StoreViewController.swift
//  Interesting_Numbers
//
//  Created by Yura Sabadin on 19.09.2023.
//

import UIKit

class StoreViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Store View Controller"
        view.backgroundColor = .tertiarySystemBackground
        setupNavButton()
    }
    
    
    @objc func addItem() {
        let addItemVC = AddProductsViewController()
        
        if let sheet = addItemVC.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 25
        }
        navigationController?.present(addItemVC, animated: true)
    }
    
    func setupNavButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addItem))
    }

}
