//
//  EnterViewController.swift
//  InterestingNumbers
//
//  Created by Yura Sabadin on 10.09.2023.
//

import UIKit

class EnterViewController: UIViewController {
    
    private let appLabel = UILabel()
    private let cubeImageView = UIImageView()
    private let tryGuestButton = UIButton(type: .system)
    private let googleButton = UIButton()
    private let appleButton = UIButton()
    private let logInButton = UIButton(type: .system)
    private var signUpStack = UIStackView()
    private var authButtonsStack = UIStackView()
    private var authorizedService = AuthorizationService.shared
    
// MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
        setDiceImageView()
        setAuthButtons()
        setLabels()
        setAuthButtonsStack()
        setSingInStack()
        setGoogleAppleButton()
        setConstraints()
    }

//MARK: - private func
    
    @objc private func goToAuthorised(_ sender: UIButton) {
        let authorizedVC = AuthorisedViewController()
        
        authorizedVC.isHaveAccount = sender == logInButton ? true : false
        navigationController?.navigationBar.isHidden = true
        navigationController?.pushViewController(authorizedVC, animated: true)
    }
    
    @objc private func goToAnonymous() {
        authorizedService.loginAnonymously { err in
            guard let err = err else {return}
            self.presentAlert(with: "Error", message: err.localizedDescription, buttonTitles: "OK", styleActionArray: [.default], alertStyle: .alert, completion: nil)
        }
    }
    
    @objc private func signUpWithGoogle() {
        authorizedService.authenticationWithGoogle(vc: self)
    }
    
    @objc private func signUpWithApple() {
        authorizedService.startSignInWithAppleFlow(vc: self) { result in
            switch result {
            case .success(let tokenResult):
                Task {
                    do {
                        try await self.authorizedService.signInWithApple(token: tokenResult)
                        
                    } catch let error {
                        self.presentAlert(with: "Error", message: error.localizedDescription, buttonTitles: "OK", styleActionArray: [.default], alertStyle: .alert, completion: nil)
                    }
                }
            case .failure(let error):
                self.presentAlert(with: "Error", message: error.localizedDescription, buttonTitles: "OK", styleActionArray: [.default], alertStyle: .alert, completion: nil)
            }
        }
    }
    
//MARK: - private func
    
    private func setView() {
        let backgroundView = UIImageView()
        backgroundView.frame = view.bounds
        backgroundView.contentMode = .scaleAspectFill
        backgroundView.image = ImageConstants.background
        view.backgroundColor = .systemBackground
        view.addSubview(backgroundView)
    }
    
    private func setDiceImageView() {
        cubeImageView.image = ImageConstants.bigDice
        cubeImageView.contentMode = .scaleAspectFit
        cubeImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cubeImageView)
    }
    
    private func setGoogleAppleButton() {
        view.addSubview(googleButton)
        googleButton.setImage(ImageConstants.googleIcon, for: .normal)
        googleButton.addTarget(self, action: #selector(signUpWithGoogle), for: .touchUpInside)
        googleButton.translatesAutoresizingMaskIntoConstraints = false
        googleButton.setBorderLayer(backgroundColor: .white, borderColor: .black, borderWidth: 1, cornerRadius: 24, tintColor: nil)
        
        view.addSubview(appleButton)
        appleButton.setImage(ImageConstants.appleIcon, for: .normal)
        appleButton.addTarget(self, action: #selector(signUpWithApple), for: .touchUpInside)
        appleButton.translatesAutoresizingMaskIntoConstraints = false
        appleButton.setBorderLayer(backgroundColor: .white, borderColor: .gray, borderWidth: 1, cornerRadius: 24, tintColor: nil)
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
        appLabel.textColor = .black
        appLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(appLabel)
    }

    private func setAuthButtonsStack() {
        authButtonsStack = UIStackView(arrangedSubviews: [logInButton, tryGuestButton])
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
            
            authButtonsStack.heightAnchor.constraint(equalToConstant: 95),
            authButtonsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            authButtonsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            googleButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -40),
            googleButton.topAnchor.constraint(equalTo: authButtonsStack.bottomAnchor, constant: 20),
            googleButton.widthAnchor.constraint(equalTo: googleButton.heightAnchor),
            googleButton.heightAnchor.constraint(equalToConstant: 45),
            
            appleButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 40),
            appleButton.topAnchor.constraint(equalTo: authButtonsStack.bottomAnchor, constant: 20),
            appleButton.widthAnchor.constraint(equalTo: googleButton.heightAnchor),
            appleButton.heightAnchor.constraint(equalToConstant: 48),
            
            signUpStack.topAnchor.constraint(equalTo: googleButton.bottomAnchor, constant: 40),
            signUpStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            signUpStack.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -40),
            signUpStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}
