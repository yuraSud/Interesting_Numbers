//
//  ChoiseRequestNumbersViewController.swift
//  InterestingNumbers
//
//  Created by Yura Sabadin on 11.09.2023.
//

import UIKit
import Combine

class ChoiseRequestNumbersViewController: UIViewController {
    
    private let nameLabel = UILabel()
    private let userButton = UIButton(type: .system)
    private let storeButton = UIButton(type: .system)
    private let scrollView = UIScrollView()
    private let choiseNumbersView = ChoiseNumbersView()
    private let validateManager = ValidateManager()
    private let authService = AuthorizationService.shared
    private let userDefaults = UserDefaults.standard
    private var cancellable = Set<AnyCancellable>()
    private var user: UserProfile?
    private var countRequest = 0
    
    
    //MARK: - Life Cycle:
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setViews()
        setupNavButton()
        sinkForUpdateUsers()
        addTarget()
        setConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.userButton.setTitle(self.user?.firstLetter ?? "?", for: .normal)
    }
    
    //MARK: - @objc Functions:
    @objc private func profileDetails() {
        let profileVC = ProfileViewController()
        
        if let sheet = profileVC.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 25
        }
        navigationController?.present(profileVC, animated: true)
    }
    
    @objc private func openStoreVc() {
        let storeVC = StoreViewController()
        storeVC.isUserAdmin = user?.isUserAdmin ?? false
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.pushViewController(storeVC, animated: true)
    }
    
    @objc private func showDescriptionNumber() {
        let typeRequest = choiseNumbersView.typeRequest
        guard let text = choiseNumbersView.inputTextField.text, !text.isEmpty else {return}
        if validateInputText(typeRequest: typeRequest, text: text) {
            let descriptionVC = DescriptionNumberViewController()
            descriptionVC.numberRequest = text
            descriptionVC.typeRequest = typeRequest
            addCountRequest()
            sendCountRequestToServer()
            navigationController?.pushViewController(descriptionVC, animated: true)
        } else {
            var title = ""
            var message = ""
            switch typeRequest {
            case .range : title = "Entered an incorrect request"
                message = "Please, enter\n number..number (like 23..45)"
            case .year : title = "Entered an incorrect request"
                message = "Please, enter\n month/day (like 8/25)"
            default: break
            }
            presentAlert(with: title, message: message, buttonTitles: "OK", styleActionArray: [.default], alertStyle: .alert, completion: nil)
        }
    }
    
    //MARK: - Functions:
    
    private func setViews() {
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.isHidden = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        choiseNumbersView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(choiseNumbersView)
        countRequest = user?.countRequest ?? 0
    }
    
    private func setupNavButton() {
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
    
    private func sinkForUpdateUsers() {
        authService.$userProfile
            .receive(on: DispatchQueue.main)
            .filter{ $0 != nil }
            .sink { profile in
                self.user = profile
                self.userButton.setTitle(self.user?.firstLetter, for: .normal)
            }.store(in: &cancellable)
        
        authService.$error
            .filter{$0 != nil}
            .sink { error in
                self.presentAlert(with: "Error", message: error?.localizedDescription, buttonTitles: "OK", styleActionArray: [.default], alertStyle: .alert, completion: nil)
            }
            .store(in: &cancellable)
    }
    
    private func addTarget() {
        choiseNumbersView.showButton.addTarget(self, action: #selector(showDescriptionNumber), for: .touchUpInside)
    }
    
    private func validateInputText (typeRequest: TypeRequest, text: String) -> Bool {
        switch typeRequest {
        case .year:
            return validateManager.isValidDate(text)
        case .range:
            return validateManager.isValidRange(text)
        default :
            return true
        }
    }
    
    private func addCountRequest() {
        guard let user else {return}
        let countRequestInMemory = userDefaults.integer(forKey: user.uid)
        if countRequest < countRequestInMemory {
            countRequest = countRequestInMemory
        }
        countRequest += 1
        userDefaults.set(countRequest, forKey: user.uid)
    }
    
    private func sendCountRequestToServer() {
        guard var user else {return}
        let countRequestInMemory = userDefaults.integer(forKey: user.uid)
        if user.countRequest < countRequestInMemory {
            self.user?.countRequest = countRequestInMemory
            user.countRequest = countRequestInMemory
            DatabaseService.shared.addCountRequest(user: user) { error in
                guard let error else {return}
                self.presentAlert(with: error.localizedDescription, message: nil, buttonTitles: "", styleActionArray: [.default], alertStyle: .alert, completion: nil)
            }
        } else {
            userDefaults.set(user.countRequest, forKey: user.uid)
        }
    }
    
    //MARK: - Set Constraints:
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            choiseNumbersView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            choiseNumbersView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            choiseNumbersView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            choiseNumbersView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            
            choiseNumbersView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
            choiseNumbersView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
}
