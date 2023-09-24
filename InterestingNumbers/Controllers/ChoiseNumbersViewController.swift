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
    private let scrollView = UIScrollView()
    private let choiseNumbersView = ChoiseNumbersView()
    private let validateManager = ValidateManager()
    let authService = AuthorizationService.shared
    var cancellable = Set<AnyCancellable>()
    var user: UserProfile?
    
    
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
        user = authService.userProfile
        self.userButton.setTitle(self.user?.firstLetter, for: .normal)
        sendCountRequestToServer()
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
    
    @objc func showDescriptionNumber() {
        let typeRequest = choiseNumbersView.typeRequest
        guard let text = choiseNumbersView.inputTextField.text, !text.isEmpty else {return}
        if validateInputText(typeRequest: typeRequest, text: text) {
            let descriptionVC = DescriptionNumberViewController()
            descriptionVC.numberRequest = text
            descriptionVC.typeRequest = typeRequest
            descriptionVC.countRequest = user?.countRequest ?? 0
            navigationController?.pushViewController(descriptionVC, animated: true)
        } else {
            alertNotCorrectInput(typeRequest)
        }
    }
        
//MARK: - Functions:
    
    func setViews() {
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.isHidden = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        choiseNumbersView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(choiseNumbersView)
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
    
    func sinkForUpdateUsers() {
        authService.$userProfile
            .receive(on: DispatchQueue.main)
            .filter{ $0 != nil }
            .sink { profile in
                self.user = profile
                self.userButton.setTitle(self.user?.firstLetter, for: .normal)
            }.store(in: &cancellable)
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
    
    private func alertNotCorrectInput(_ typeRequest: TypeRequest) {
        var alert = UIAlertController()
        switch typeRequest {
        case .range : alert = UIAlertController(title: "Entered an incorrect request", message: "Please, enter\n number..number (like 23..45)", preferredStyle: .alert)
        case .year : alert = UIAlertController(title: "Entered an incorrect request", message: "Please, enter\n month/day (like 8/25)", preferredStyle: .alert)
        default : return
        }
        let alertActionOK = UIAlertAction(title: "Ok", style: .default) { _ in
            self.choiseNumbersView.inputTextField.text = ""
        }
        alert.addAction(alertActionOK)
        present(alert, animated: true)
    }
    
    func sendCountRequestToServer() {
        guard var user else {return}
        let userDefaults = UserDefaults.standard
        let countRequestInMemory = userDefaults.integer(forKey: "countRequest")
        if user.countRequest < countRequestInMemory {
            self.user?.countRequest = countRequestInMemory
            user.countRequest = countRequestInMemory
            DatabaseService.shared.addCountRequest(user: user) { error in
                guard let error else {return}
                self.presentAlert(with: error.localizedDescription, message: nil, buttonTitles: "", styleActionArray: [.default], alertStyle: .alert, completion: nil)
            }
        } else {
            userDefaults.set(user.countRequest, forKey: "countRequest")
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
