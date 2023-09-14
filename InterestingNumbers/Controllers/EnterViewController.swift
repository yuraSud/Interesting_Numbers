//
//  EnterViewController.swift
//  InterestingNumbers
//
//  Created by Olga Sabadina on 10.09.2023.
//

import UIKit

class EnterViewController: UIViewController {
    
    let appLabel = UILabel()
    let cubeImageView = UIImageView()
    var logInButton = UIButton(type: .system)
    let tryGuestButton = UIButton(type: .system)
    var authButtonsStack = UIStackView()
    var signUpStack = UIStackView()
    let authService = AuthorizationService.shared
    
// MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
        setCubeImageView()
        setAuthButtons()
        setLabels()
        setAuthButtonsStack()
        setSingInStack()
        setConstraints()
    }

//MARK: - private func
    
    @objc func goToAuthorised(_ sender: UIButton) {
        let authorizedVC = AuthorisedViewController()
        
        if sender == logInButton {
            authorizedVC.isHaveAccount = true
        } else {
            authorizedVC.isHaveAccount = false
        }
        navigationController?.navigationBar.isHidden = true
        navigationController?.pushViewController(authorizedVC, animated: true)
    }
    
    @objc func goToAnonymous() {
        authService.loginAnonymously { err in
            guard let err = err else {return}
            self.presentAlert(with: "Error", message: err.localizedDescription, buttonTitles: "OK", styleActionArray: [.default], alertStyle: .alert, completion: nil)
        }
    }
    
//MARK: - private func
    
    private func setView() {
        let backgroundView = UIImageView()
        view.backgroundColor = .systemBackground
        view.addSubview(backgroundView)
        backgroundView.frame = view.bounds
        backgroundView.contentMode = .scaleAspectFill
        backgroundView.image = ImageConstants.background
    }
    
    private func setCubeImageView() {
        cubeImageView.image = ImageConstants.bigDice
        cubeImageView.contentMode = .scaleAspectFit
        cubeImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cubeImageView)
    }
    
    private func setAuthButtons() {
        let buttons = [logInButton, tryGuestButton]
        buttons.forEach { button in
            button.layer.cornerRadius = 10
            button.layer.borderColor = UIColor.gray.cgColor
            button.layer.borderWidth = 1
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        }
        logInButton.setTitle(TitleConstants.logInButton, for: .normal)
        logInButton.backgroundColor = .link
        logInButton.tintColor = .systemBackground
        logInButton.addTarget(self, action: #selector(goToAuthorised(_:)), for: .touchUpInside)
        
        tryGuestButton.setTitle(TitleConstants.tryGuestButton, for: .normal)
        tryGuestButton.backgroundColor = .systemBackground
        tryGuestButton.tintColor = .black
        tryGuestButton.addTarget(self, action: #selector(goToAnonymous), for: .touchUpInside)
    }
    
    private func setLabels() {
        appLabel.text = TitleConstants.titleLabel
        appLabel.font = .boldSystemFont(ofSize: 24)
        appLabel.textColor = .white
        appLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(appLabel)
    }

    private func setAuthButtonsStack() {
        authButtonsStack = UIStackView(arrangedSubviews: [logInButton, tryGuestButton,])
        authButtonsStack.axis = .vertical
        authButtonsStack.spacing = 10
        authButtonsStack.distribution = .fillEqually
        authButtonsStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(authButtonsStack)
    }
    
    private func setSingInStack() {
        let signUpLabel = UILabel()
        signUpLabel.text = TitleConstants.signUpLabel
        signUpLabel.textColor = .white
        signUpLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        let signUpButton = UIButton(type: .system)
        signUpButton.setTitle(TitleConstants.signUpButton, for: .normal)
        signUpButton.tintColor = .link
        signUpButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        signUpButton.addTarget(self, action: #selector(goToAuthorised(_:)), for: .touchUpInside)
        
        signUpStack = UIStackView(arrangedSubviews: [signUpLabel, signUpButton])
        signUpStack.axis = .horizontal
        signUpStack.spacing = 4
        signUpStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(signUpStack)
    }
    
 //MARK: - Constraints
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            appLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            appLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            cubeImageView.topAnchor.constraint(equalTo: appLabel.bottomAnchor, constant: 35),
            cubeImageView.heightAnchor.constraint(equalToConstant: 250),
            cubeImageView.widthAnchor.constraint(equalTo: cubeImageView.heightAnchor),
            cubeImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            authButtonsStack.heightAnchor.constraint(equalToConstant: 100),
            authButtonsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            authButtonsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            signUpStack.topAnchor.constraint(equalTo: authButtonsStack.bottomAnchor, constant: 40),
            signUpStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            signUpStack.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -40),
            signUpStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}
