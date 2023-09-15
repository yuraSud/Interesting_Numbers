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
        fetchUser()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

    }
    
//MARK: - @objc Functions:
    @objc func profileDetails() {
        
        let profileVC = ProfileViewController()
        if let user = user {
            profileVC.setLabelsText(user: user)
        } else {
            let user = UserProfile(name: "?", email: "Anonymous@mail.com")
            profileVC.setLabelsText(user: user)
        }
        if let sheet = profileVC.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 25
        }
        navigationController?.present(profileVC, animated: true)
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
    }
    
    func fetchUser() {
        let isAnonym = authService.userIsAnonymously()
        updateLabels(isAnonym)
    }
    
    func updateLabels(_ isAnonymously: Bool) {
        let title = isAnonymously ? "?" : user?.firstLetter
        userButton.setTitle(title, for: .normal)
        nameLabel.text = isAnonymously ? "I am anonymously" : "\(user?.name ?? "not name") have email\n \(user?.email ?? "not email"), \nand\n uid = \(authService.uid)"
    }
    
    func sinkForUpdateUsers() {
        authService.$userProfile
            .receive(on: DispatchQueue.main)
            .filter{ $0 != nil }
            .sink { profile in
                self.user = profile
                self.fetchUser()
            }.store(in: &cancellable)
    }
}
