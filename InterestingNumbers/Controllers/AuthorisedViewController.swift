//
//  AythorizedViewController.swift
//  InterestingNumbers
//
//  Created by Olga Sabadina on 09.09.2023.
//

import UIKit

class AuthorisedViewController: UIViewController {
    
    let authoriseView = AuthorisedView()
    var isHaveAccount = false
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        addTargetForButtons()
        haveAccount(isHaveAccount)
   }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setConstraints()
    }
    
    private func setupView() {
        let backgroundView = UIImageView()
        backgroundView.frame = view.bounds
        backgroundView.contentMode = .scaleAspectFill
        backgroundView.image = ImageConstants.backgroundAuthorized
        
        authoriseView.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        view.addSubview(backgroundView)
        view.addSubview(authoriseView)
    }
    
//MARK: - @objc Function:
    @objc func goToSignIn() {
        guard let enterVC = navigationController?.viewControllers.first(where: {$0.isKind(of: EnterViewController.self) }) as? EnterViewController else {
            print("Nothin EnterVC in NavStack")
            return
        }
        navigationController?.popToViewController(enterVC, animated: true)
    }
    
    @objc func forgotPassword() {
        print("forget pass")
        //TODO: - Forgot password
    }
    
    @objc func logIn(_ sender: UIButton) {
        if sender.tag == 0 {
            print("log in")
        } else {
            print("register")
        }
    }
    
    private func addTargetForButtons() {
        authoriseView.signInButton.addTarget(self, action: #selector(goToSignIn), for: .touchUpInside)
        authoriseView.forgetButton.addTarget(self, action: #selector(forgotPassword), for: .touchUpInside)
        authoriseView.loginButton.addTarget(self, action: #selector(logIn(_:)), for: .touchUpInside)
    }
    
    private func haveAccount(_ isHaveAccount: Bool) {
        if isHaveAccount {
            authoriseView.nameTextField.isHidden = true
            authoriseView.setFogetPasswordButton()
            authoriseView.setLoginButton(isHaveAccount)
        } else {
            authoriseView.setLoginButton(isHaveAccount)
        }
    }
    
//MARK: - constraints:
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            authoriseView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            authoriseView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            authoriseView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            authoriseView.leadingAnchor.constraint(equalTo: view.leadingAnchor)

        ])
    }
}

