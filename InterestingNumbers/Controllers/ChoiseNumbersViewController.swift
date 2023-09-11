//
//  ChoiseNumbersViewController.swift
//  InterestingNumbers
//
//  Created by Yura Sabadin on 11.09.2023.
//

import UIKit

class ChoiseNumbersViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setViews()
        setupNavButton()
       
    }
    
    func setViews() {
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.isHidden = false
    }
    
    func setupNavButton() {
        let button = UIButton(type: .system)
        button.frame = .init(x: 0, y: 0, width: 40, height: 40)
        button.titleLabel?.sizeToFit()
        button.titleLabel?.font = .boldSystemFont(ofSize: 20)
        button.clipsToBounds = true
        button.setTitle("Y", for: .normal)
        button.layer.cornerRadius = button.bounds.size.width / 2
        button.backgroundColor = .systemMint
        button.addTarget(self, action: #selector(logOut), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
    }
    
    @objc func logOut() {
        let alertController = UIAlertController(title: "Do you want Log out?", message: nil, preferredStyle: .actionSheet)
        let actionLogOut = UIAlertAction(title: "Log Out", style: .default) { _ in
            //log out
            self.navigationController?.setViewControllers([EnterViewController()], animated: true)
           // self.navigationController?.popToRootViewController(animated: true)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(actionLogOut)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }

}
