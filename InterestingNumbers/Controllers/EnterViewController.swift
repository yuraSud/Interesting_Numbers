//
//  EnterViewController.swift
//  InterestingNumbers
//
//  Created by Olga Sabadina on 10.09.2023.
//

import UIKit
import GoogleSignIn
import AuthenticationServices
import FirebaseAuth
import CryptoKit

import Foundation
import Firebase
import FirebaseFirestore


class EnterViewController: UIViewController {
    
    let appLabel = UILabel()
    let cubeImageView = UIImageView()
    var logInButton = UIButton(type: .system)
    let tryGuestButton = UIButton(type: .system)
    var authButtonsStack = UIStackView()
    var signUpStack = UIStackView()
    let authService = AuthorizationService.shared
    let googleButton = UIButton()
    let appleButton = UIButton()
    
    var currentNonce: String? //Apple authorization
    
// MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
        setCubeImageView()
        setAuthButtons()
        setLabels()
        setAuthButtonsStack()
        setSingInStack()
        setGoogleAppleButton()
        setConstraints()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
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
    
    @objc func signUpWithGoogle() {
        authService.authenticationWithGoogle(vc: self)
    }
    
    @objc func signUpWithApple() {
        authService.startSignInWithAppleFlow(vc: self) { result in
            switch result {
            case .success(let tokenResult):
                Task {
                    do {
                        try await self.authService.signInWithApple(token: tokenResult)
                        
                    } catch let err {
                        self.presentAlert(with: "Error", message: err.localizedDescription, buttonTitles: "OK", styleActionArray: [.default], alertStyle: .alert, completion: nil)
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

//extension EnterViewController: ASAuthorizationControllerPresentationContextProviding, ASAuthorizationControllerDelegate {
//
//    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
//        guard let window = self.view.window else {return ASPresentationAnchor()}
//        return window
//    }
//
//    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
//
//        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
//              let nonce = currentNonce,
//              let appleIDToken = appleIDCredential.identityToken,
//              let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
//            print("Error return token")
//            return
//        }
//
//        let credential = OAuthProvider.credential(withProviderID: "apple.com",
//                                                          idToken: idTokenString,
//                                                          rawNonce: nonce)
//          // Sign in with Firebase.
//            Auth.auth().signIn(with: credential) { result, error in
//                guard error == nil else {
//                    print("auth error")
//                    return
//                }
//                guard let user = result?.user else {return}
//                self.uid = user.uid
//                guard !user.isAnonymous else {return}
//                self.fetchProfile() { error in
//                    guard let error = error else {return}
//                    self.error = error
//                }
//            }
//        }
//
//    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
//        // Handle error.
//        print("Sign in with Apple errored: \(error)")
//      }
//
//    private func randomNonceString(length: Int = 32) -> String {
//      precondition(length > 0)
//      var randomBytes = [UInt8](repeating: 0, count: length)
//      let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
//      if errorCode != errSecSuccess {
//        fatalError(
//          "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
//        )
//      }
//      let charset: [Character] =
//        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
//
//      let nonce = randomBytes.map { byte in
//        // Pick a random character from the set, wrapping around if needed.
//        charset[Int(byte) % charset.count]
//      }
//      return String(nonce)
//    }
//
//    private func sha256(_ input: String) -> String {
//      let inputData = Data(input.utf8)
//      let hashedData = SHA256.hash(data: inputData)
//      let hashString = hashedData.compactMap {
//        String(format: "%02x", $0)
//      }.joined()
//
//      return hashString
//    }
//
//    func startSignInWithAppleFlow(vc: UIViewController) {
//        let nonce = randomNonceString()
//        currentNonce = nonce
//        let appleIDProvider = ASAuthorizationAppleIDProvider()
//        let request = appleIDProvider.createRequest()
//        request.requestedScopes = [.fullName, .email]
//        request.nonce = sha256(nonce)
//
//        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
//        authorizationController.delegate = self
//        authorizationController.presentationContextProvider = self
//        authorizationController.performRequests()
//    }
//}
