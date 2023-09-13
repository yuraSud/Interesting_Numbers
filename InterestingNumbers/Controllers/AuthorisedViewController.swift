//
//  AythorizedViewController.swift
//  InterestingNumbers
//
//  Created by Olga Sabadina on 09.09.2023.
//

import UIKit

class AuthorisedViewController: UIViewController {
    
    let authoriseView = AuthorisedView()
    let scrollView = UIScrollView()
    var isHaveAccount = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        addTargetForButtons()
        haveAccount(isHaveAccount)
        setConstraints()
   }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    private func setupView() {
        let backgroundView = UIImageView()
        backgroundView.frame = view.bounds
        backgroundView.contentMode = .scaleAspectFill
        backgroundView.image = ImageConstants.backgroundAuthorized

        authoriseView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        view.backgroundColor = .systemBackground
        view.addSubview(backgroundView)
        view.addSubview(scrollView)
        scrollView.addSubview(authoriseView)
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
        print(navigationController?.viewControllers.count ?? 100, "Count nav")
        //TODO: - Forgot password
    }
    
    @objc func logIn(_ sender: UIButton) {
        if sender.tag == 0 {
            print("log in")
        } else {
            print("register")
        }
        self.navigationController?.setViewControllers([ChoiseNumbersViewController()], animated: true)
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
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            
            authoriseView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            authoriseView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            authoriseView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            authoriseView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            
            authoriseView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            authoriseView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])
    }
}
