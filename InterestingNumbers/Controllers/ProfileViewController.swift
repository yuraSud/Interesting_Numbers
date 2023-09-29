//
//  ProfileViewController.swift
//  Interesting_Numbers
//
//  Created by Yura Sabadin on 15.09.2023.
//

import UIKit
import Combine

class ProfileViewController: UIViewController {
    
    private let usersImageLabel = UILabel()
    private let nameUserLabel = UILabel()
    private let emailUserLabel = UILabel()
    private let countRequestLabel = UILabel()
    private let editProfileButton = UIButton(type: .system)
    private let deletProfileButton = UIButton(type: .system)
    private let logOutProfileButton = UIButton(type: .system)
    private let cancelButton = UIButton(type: .system)
    private let authService = AuthorizationService.shared
    private var stackButtons = UIStackView()
    private var labelStack = UIStackView()
    private var subscribers = Set<AnyCancellable>()
    private var user: UserProfile?
    
//MARK: - Life cycle:
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        setStackButtons()
        configLabelsStack()
        setCloseButton()
        setConstraints()
        addTargetButton()
        fetchCurrentUser()
        updateUser()
    }
    
//MARK: - Fuctions:
    
    private func updateUser() {
        authService.$userProfile
            .receive(on: DispatchQueue.main)
            .filter{ $0 != nil }
            .sink { profile in
                self.user = profile
                self.setLabelsText()
            }.store(in: &subscribers)
        
        authService.$error
            .filter{$0 != nil}
            .sink { error in
                self.presentAlert(with: "Error", message: error?.localizedDescription, buttonTitles: "OK", styleActionArray: [.default], alertStyle: .alert, completion: nil)
            }
            .store(in: &subscribers)
    }
    
    private func fetchCurrentUser() {
        guard !authService.userIsAnonymously() else {
            self.user = UserProfile(name: "?", email: "Anonymous@mail.com")
            setLabelsText()
            self.editProfileButton.isHidden = true
            return}
        
        authService.getProfileDocuments()
        self.editProfileButton.isHidden = false
        setLabelsText()
    }
    
    private func setLabelsText() {
        guard let user else {return}
        nameUserLabel.text = "name: \(user.name)"
        emailUserLabel.text = "email: \(user.email)"
        usersImageLabel.text = user.firstLetter
        countRequestLabel.text = "Count request: \(user.countRequest)"
    }
    
//MARK: - @objc Functions:
    
    @objc private func closeVC() {
        self.dismiss(animated: true)
    }
    
    @objc private func logOut() {
        self.authService.logOut()
        closeVC()
    }
    
    @objc private func deleteUser() {
        defer {
            closeVC()
        }
        self.authService.deleteUser(vc: self) { error in
            guard let error else {return}
            self.presentAlert(with: "Error", message: error.localizedDescription, buttonTitles: "OK", styleActionArray: [.default], alertStyle: .alert, completion: nil)
        }
    }
    
    @objc private func editUserProfile() {
        editProfileAlert()
    }
    
//MARK: - private Functions:
    
    private func setCloseButton() {
        view.addSubview(cancelButton)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.addTarget(self, action: #selector(closeVC), for: .touchUpInside)
        cancelButton.setImage(UIImage(systemName: "multiply"), for: .normal)
        cancelButton.setBorderLayer(backgroundColor: .black, borderColor: .gray, borderWidth: 2, cornerRadius: 15, tintColor: .white)
    }
    
    private func configLabelsStack() {
        usersImageLabel.sizeToFit()
        usersImageLabel.layer.cornerRadius = 40
        usersImageLabel.font = .boldSystemFont(ofSize: 45)
        usersImageLabel.tintColor = .white
        usersImageLabel.backgroundColor = .systemMint
        usersImageLabel.textAlignment = .center
        usersImageLabel.clipsToBounds = true
        nameUserLabel.font = .systemFont(ofSize: 19)
        nameUserLabel.textAlignment = .left
        emailUserLabel.font = .systemFont(ofSize: 18)
        emailUserLabel.textAlignment = .left
        emailUserLabel.adjustsFontSizeToFitWidth = true
        
        let labelRightStack = UIStackView(arrangedSubviews: [nameUserLabel,emailUserLabel,countRequestLabel])
        labelRightStack.axis = .vertical
        labelRightStack.spacing = 5
        labelRightStack.distribution = .fillEqually
        
        labelStack = UIStackView(arrangedSubviews: [usersImageLabel,labelRightStack])
        labelStack.axis = .horizontal
        labelStack.spacing = 30
        labelStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(labelStack)
    }
    
    private func setStackButtons() {
        let buttons = [editProfileButton, logOutProfileButton, deletProfileButton]
        let titleArr = ["Edit profile", "Log Out", "Delete profile"]
        buttons.enumerated().forEach { index, button in
            button.setTitle(titleArr[index], for: .normal)
            button.heightAnchor.constraint(equalToConstant: 40).isActive = true
            button.setBorderLayer(backgroundColor: .link, borderColor: .gray, borderWidth: 2, cornerRadius: 20, tintColor: .white)
            button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        }
        editProfileButton.isEnabled = true
        stackButtons = UIStackView(arrangedSubviews: buttons)
        stackButtons.axis = .vertical
        stackButtons.spacing = 18
        stackButtons.distribution = .fillEqually
        stackButtons.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackButtons)
    }
    
    private func addTargetButton() {
        logOutProfileButton.addTarget(self, action: #selector(logOut), for: .touchUpInside)
        deletProfileButton.addTarget(self, action: #selector(deleteUser), for: .touchUpInside)
        editProfileButton.addTarget(self, action: #selector(editUserProfile), for: .touchUpInside)
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            labelStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            labelStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            labelStack.topAnchor.constraint(equalTo: view.topAnchor, constant: 40),
            labelStack.heightAnchor.constraint(equalToConstant: 80),
            
            stackButtons.topAnchor.constraint(equalTo: labelStack.bottomAnchor, constant: 60),
            stackButtons.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackButtons.widthAnchor.constraint(equalTo: labelStack.widthAnchor),
            
            cancelButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            cancelButton.heightAnchor.constraint(equalTo: cancelButton.widthAnchor),
            cancelButton.widthAnchor.constraint(equalToConstant: 30),
            cancelButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 15),
            
            usersImageLabel.widthAnchor.constraint(equalTo: usersImageLabel.heightAnchor)
        ])
    }
    
    private func editProfileAlert() {
        let alert = UIAlertController(title: "Edit profile", message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            guard let name = alert.textFields?.first?.text,
                  !name.isEmpty,
                  let email = alert.textFields?.last?.text,
                  !email.isEmpty,
                  var user = self.user
            else {
                self.presentAlert(with: "Error", message: "Fields must not be empty", buttonTitles: "OK", styleActionArray: [.default], alertStyle: .alert, completion: nil)
                return
            }
            
            user.name = name
            user.email = email
            
            DatabaseService.shared.sendProfileToServer(uid: user.uid, profile: user) { error in
                self.presentAlert(with: "Error", message: error?.localizedDescription, buttonTitles: "OK", styleActionArray: [.default], alertStyle: .alert, completion: nil)
            }
            self.fetchCurrentUser()
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
       
        alert.addAction(okAction)
        alert.addAction(cancelAction)
       
        alert.addTextField { nameTF in
            nameTF.placeholder = "name"
            nameTF.text = self.user?.name
            nameTF.clearButtonMode = .whileEditing
            nameTF.autocorrectionType = .no
            nameTF.autocapitalizationType = .none
        }
        alert.addTextField { emailTF in
            emailTF.placeholder = "email"
            emailTF.text = self.user?.email
            emailTF.clearButtonMode = .whileEditing
            emailTF.autocorrectionType = .no
            emailTF.autocapitalizationType = .none
        }
        present(alert, animated: true)
    }
}
