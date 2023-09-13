//
//  AythorizedViewController.swift
//  InterestingNumbers
//
//  Created by Olga Sabadina on 09.09.2023.
//

import FirebaseFirestoreSwift
import UIKit
import Firebase
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

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
        
        let alert = UIAlertController(title: "Forgot Password", message: "you can reset your password", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "enter amail"
        }
        let alertActionOk = UIAlertAction(title: "OK", style: .default) { _ in
            guard let email = alert.textFields?.first?.text else {return}
            Auth.auth().sendPasswordReset(withEmail: email) { error in
                guard let error else {return}
                print(error.localizedDescription)
            }
        }
        alert.addAction(alertActionOk)
        present(alert, animated: true)
        //TODO: - Forgot password
    }
    
    @objc func logIn(_ sender: UIButton) {
        
        guard let email = authoriseView.emailTextField.text,
              let password = authoriseView.passwordTextField.text
        else {return}
        let man = Profile(name: authoriseView.nameTextField.text ?? "", email: email, age: 55)
        var uid = ""
        if sender.tag == 0 {
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                if let err = error {
                    print(err.localizedDescription)
                    return
                } else {
                    switch result {
                    case .none:
                        print("none")
                    case .some(let data):
                        print(data.user.email ?? "doesn't receive user")
                        self.navigationController?.setViewControllers([ChoiseNumbersViewController()], animated: true)
                    }
                }
            }
        } else {
           
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                if let err = error {
                    print(err.localizedDescription)
                    return
                } else {
                    uid = result?.user.uid ?? "yura"
                    do {
                        try Firestore.firestore().collection("users").document(uid).setData(from: man)
                    } catch {
                        print("Error send data")
                    }
                }
                self.navigationController?.setViewControllers([ChoiseNumbersViewController()], animated: true)
            }
//                try await Firestore.firestore().collection("users").document("oll")
//                    .setData([
//                        "name": authoriseView.nameTextField.text ?? "",
//                        "email": email,
//                        "age": 34
//                             ])
            print("register")
        }
       // self.navigationController?.pushViewController(ChoiseNumbersViewController(), animated: true)
//        self.navigationController?.setViewControllers([ChoiseNumbersViewController()], animated: true)
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
