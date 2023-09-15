//
//  ProfileViewController.swift
//  Interesting_Numbers
//
//  Created by Yura Sabadin on 15.09.2023.
//

import UIKit

class ProfileViewController: UIViewController {
    
    let usersImageLabel = UILabel()
    let nameUserLabel = UILabel()
    let emailUserLabel = UILabel()
    let editProfileButton = UIButton(type: .system)
    let deletProfileButton = UIButton(type: .system)
    let logOutProfileButton = UIButton(type: .system)
    let cancelButton = UIButton(type: .system)
    var stackButtons = UIStackView()
    var labelStack = UIStackView()
    let authService = AuthorizationService.shared
    
//MARK: - Life cycle:
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        setStackButtons()
        configLabelsStack()
        setCloseButton()
        setConstraints()
        addTargetButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
//MARK: - Fuctions:
    
    func setLabelsText(user: UserProfile) {
        nameUserLabel.text = "name: \(user.name)"
        emailUserLabel.text = "email: \(user.email)"
        usersImageLabel.text = user.firstLetter
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
        self.authService.deleteUser { error in
            guard let error else {return}
            
            self.presentAlert(with: "Error", message: error.localizedDescription, buttonTitles: "OK", styleActionArray: [.default], alertStyle: .alert, completion: nil)
        }
        closeVC()
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
        
        let labelRightStack = UIStackView(arrangedSubviews: [nameUserLabel,emailUserLabel])
        labelRightStack.axis = .vertical
        labelRightStack.spacing = 8
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
        editProfileButton.isEnabled = false
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
}
