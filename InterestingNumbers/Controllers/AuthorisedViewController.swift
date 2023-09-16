//
//  AythorizedViewController.swift
//  InterestingNumbers
//
//  Created by Yura Sabadin on 09.09.2023.
//

//import FirebaseFirestoreSwift
import UIKit
//import Firebase
//import FirebaseCore
//import FirebaseFirestore
//import FirebaseAuth
import Combine

class AuthorisedViewController: UIViewController {
    
    let authoriseView = AuthorisedView()
    let scrollView = UIScrollView()
    let authService = AuthorizationService.shared
    var isHaveAccount = false
    var viewModelAuthorized: AuthorizationViewModel?
    var cancellable = Set<AnyCancellable>()

//MARK: - Life cycle:
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        addTargetForButtons()
        haveAccount(isHaveAccount)
        setConstraints()
        setViewModel()
        setTextFieldPublishers()
   }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
//MARK: - @objc Functions:
    
    @objc func goToSignIn() {
        if isHaveAccount {
            isHaveAccount = false
            haveAccount(false)
        } else {
            guard let enterVC = navigationController?.viewControllers.first(where: {$0.isKind(of: EnterViewController.self) }) as? EnterViewController else {
                navigationController?.popToViewController(EnterViewController(), animated: true)
                return
            }
            navigationController?.popToViewController(enterVC, animated: true)
        }
    }
    
    @objc func forgotPassword() {
        print(navigationController?.viewControllers.count ?? 100, "Count nav") //Delete this row!!!
        let alert = UIAlertController(title: "Do you want to reset password?", message: "use your email...", preferredStyle: .alert)
        
        let alertActionOk = UIAlertAction(title: "OK", style: .default) { _ in
            guard let email = alert.textFields?.first?.text else {return}
            self.authService.resetPasswordByEmail(email: email) { error in
                guard let error else {return}
                self.presentAlert(with: "Error", message: "\(error.localizedDescription)", buttonTitles: "OK", styleActionArray: [.default], alertStyle: .alert, completion: nil)
            }
        }
        let alertActionCancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(alertActionOk)
        alert.addAction(alertActionCancel)
        alert.addTextField { textField in
            textField.placeholder = "enter your email"
        }
        present(alert, animated: true)
    }
    
    @objc func pushLogInButton(_ sender: UIButton) {
       
        //TODO: - ViewModel:....!!!!
        
        guard let email = authoriseView.emailTextField.text,
              let password = authoriseView.passwordTextField.text
        else {return}
        let man = UserProfile(name: authoriseView.nameTextField.text ?? "Bot", email: email)
        authService.userProfile = man
        
        if sender.tag == 0 {
            authoriseView.animating.startAnimating()
            authService.logIn(email: email, pasword: password) { [weak self] error in
                self?.authoriseView.animating.stopAnimating()
                self?.presentAlert(with: "Error", message: error.localizedDescription, buttonTitles: "OK", styleActionArray: [.default], alertStyle: .alert, completion: nil)
            }
            
        } else {
            authoriseView.animating.startAnimating()
            self.authService.signUp(email, password, profile: man) { [weak self] error in
                guard let error = error else {return}
                self?.authoriseView.animating.stopAnimating()
                self?.presentAlert(with: "Error", message: error.localizedDescription, buttonTitles: "OK", styleActionArray: [.default], alertStyle: .alert, completion: nil)
            }
            print("register")
        }
    }
    
//MARK: - Functions:
    
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
    
    private func addTargetForButtons() {
        authoriseView.signInButton.addTarget(self, action: #selector(goToSignIn), for: .touchUpInside)
        authoriseView.forgetButton.addTarget(self, action: #selector(forgotPassword), for: .touchUpInside)
        authoriseView.loginButton.addTarget(self, action: #selector(pushLogInButton(_:)), for: .touchUpInside)
    }
    
    private func haveAccount(_ isHaveAccount: Bool) {
        authoriseView.isHaveAccount = isHaveAccount
    }
    
    private func setViewModel() {
        viewModelAuthorized = AuthorizationViewModel(authService: authService)
        
        viewModelAuthorized?.$isBusyEmail
            .sink(receiveValue: { isBusy in
                if self.isHaveAccount {
                    self.authoriseView.emailTextField.emailIsExists(isExists: isBusy)
                } else {
                    self.authoriseView.emailTextField.emailAlreadyBusy(isBusy: isBusy)
                }
                self.authoriseView.emailTextField.animating?.stopAnimating()
            })
            .store(in: &cancellable)
        
        viewModelAuthorized?.registerIsEnable
            .sink(receiveValue: { isRegister in
                if !self.isHaveAccount {
                    self.authoriseView.loginButton.isEnabled = isRegister
                }
            })
            .store(in: &cancellable)
        
        viewModelAuthorized?.logInIsEnable
            .sink(receiveValue: { isLogIn in
                if self.isHaveAccount {
                    self.authoriseView.loginButton.isEnabled = isLogIn
                }
            })
            .store(in: &cancellable)
        
        viewModelAuthorized?.$email
            .debounce(for: 0.8, scheduler: DispatchQueue.main)
            .removeDuplicates()
            .filter{!$0.isEmpty && $0.contains("@") && $0.contains(".")}
            .sink { _ in
                self.authoriseView.emailTextField.animating?.startAnimating()
            }.store(in: &cancellable)
    }
    
    private func setTextFieldPublishers() {
        guard let viewModel = viewModelAuthorized else {return}
        authoriseView.emailTextField.textPublisher
            .assign(to: \.email, on: viewModel)
            .store(in: &cancellable)
        
        authoriseView.nameTextField.textPublisher
            .assign(to: \.name, on: viewModel)
            .store(in: &cancellable)
        
        authoriseView.passwordTextField.textPublisher
            .assign(to: \.password, on: viewModel)
            .store(in: &cancellable)
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
