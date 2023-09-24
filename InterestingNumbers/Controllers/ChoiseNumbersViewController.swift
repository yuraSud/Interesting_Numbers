//
//  ChoiseNumbersViewController.swift
//  InterestingNumbers
//
//  Created by Yura Sabadin on 11.09.2023.
//

import UIKit

import Combine


class ChoiseNumbersViewController: UIViewController {
    
    let nameLabel = UILabel()
    let userButton = UIButton(type: .system)
    let storeButton = UIButton(type: .system)
    let authService = AuthorizationService.shared
    var cancellable = Set<AnyCancellable>()
    var user: UserProfile?
    
    
//MARK: - Life Cycle:

    override func viewDidLoad() {
        super.viewDidLoad()
        setViews()
        setupNavButton()
        setNameLabel() //Dele in Future
        sinkForUpdateUsers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        user = authService.userProfile
        updateLabels()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

    }
    
//MARK: - @objc Functions:
    @objc func profileDetails() {
        let profileVC = ProfileViewController()
        
        if let sheet = profileVC.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 25
        }
        navigationController?.present(profileVC, animated: true)
    }
    
    @objc func openStoreVc() {
        let storeVC = StoreViewController()
        storeVC.isUserAdmin = user?.isUserAdmin ?? false
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.pushViewController(storeVC, animated: true)
    }
        
//MARK: - Functions:
    
    func setNameLabel() {
        nameLabel.frame = view.bounds
        nameLabel.numberOfLines = 0
        nameLabel.textAlignment = .center
        view.addSubview(nameLabel)
    }
    
    func setViews() {
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.isHidden = false
    }
    
    func setupNavButton() {
        userButton.frame = .init(x: 0, y: 0, width: 40, height: 40)
        userButton.titleLabel?.sizeToFit()
        userButton.titleLabel?.font = .boldSystemFont(ofSize: 20)
        userButton.clipsToBounds = true
        userButton.titleLabel?.tintColor = .white
        userButton.layer.cornerRadius = userButton.bounds.size.width / 2
        userButton.backgroundColor = .systemMint
        userButton.addTarget(self, action: #selector(profileDetails), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: userButton)
        
        storeButton.frame = .init(x: 0, y: 0, width: 40, height: 40)
        storeButton.tintColor = .white
        storeButton.clipsToBounds = true
        storeButton.backgroundColor = .systemMint
        storeButton.layer.cornerRadius = storeButton.bounds.size.width / 2
        storeButton.addTarget(self, action: #selector(openStoreVc), for: .touchUpInside)
        storeButton.setImage(ImageConstants.rightBarButton, for: .normal)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: storeButton)
    }
    
    func updateLabels() {
        let title = user?.firstLetter
        let navCount = navigationController?.viewControllers.count ?? 100
        print("nav count", navCount)
        userButton.setTitle(title, for: .normal)
        nameLabel.text = "\(user?.name ?? "not name") have email\n \(user?.email ?? "not email"), \nand\n uid = \(authService.uid)\n count nav = \(navCount)"
    }
    
    func sinkForUpdateUsers() {
        authService.$userProfile
            .receive(on: DispatchQueue.main)
            .filter{ $0 != nil }
            .sink { profile in
                self.user = profile
                self.updateLabels()
            }.store(in: &cancellable)
    }
}
