//
//  AuthenticationManager.swift
//  Interesting_Numbers
//
//  Created by Yura Sabadin on 14.09.2023.
//

import Foundation
import Firebase
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine
import FirebaseAuth
import GoogleSignIn
import AuthenticationServices

final class AuthorizationService: NSObject, ASAuthorizationControllerDelegate {
    
    @Published var userProfile: UserProfile?
    @Published var sessionState: SessionState = .loggedOut
    @Published var uid = ""
    @Published var error: Error? {
        didSet {
            print(error?.localizedDescription ?? "Not parce error", "___Error Authorization Manager")
        }
    }
    
    var completionResultTokenApple: ((Result<SignInWithAppleResult, Error>)-> Void)?
    var completionStringToken: ((String)->())?
    
    private var currentNonce: String? //Apple authorization string
    private var cancellables = Set<AnyCancellable>()
    private var handle: AuthStateDidChangeListenerHandle?
    
    static let shared = AuthorizationService()
    private override init() {}
    
    func setupFirebaseAuth() {
        handle = Auth.auth().addStateDidChangeListener {[weak self] auth, user in
            guard let self = self else {return}
            self.sessionState = user == nil ? .loggedOut : .loggedIn
            guard let user = user else {return}
            self.uid = user.uid
            guard !user.isAnonymous else {return}
            self.getProfileDocuments()
        }
    }
    
    func getProfileDocuments() {
        DatabaseService.shared.fetchProfile(uid: uid) { result in
            switch result {
            case .success(let userProfile):
                self.userProfile = userProfile
            case .failure(let error):
                self.error = error
                self.userProfile = nil
            }
        }
    }
    
    func signUp(_ email: String, _ pasword: String, profile: UserProfile?, errorHandler: ((Error?)->Void)?) {
        guard var profile = profile else {return}
       
        Auth.auth().createUser(withEmail: email, password: pasword) { [weak self] result, error in
            if let error = error {
                errorHandler?(error)
            } else {
                guard let user = result?.user else {
                    errorHandler?(AuthorizeError.userNotFound)
                    return}
            
                let uid = user.uid
                self?.uid = uid
                profile.uid = uid
                DatabaseService.shared.sendProfileToServer(uid: uid, profile: profile) { error in
                    errorHandler?(error)
                }
            }
        }
    }
    
    func logIn(email: String, pasword: String, errorHandler: ((Error)->Void)?) {
        Auth.auth().signIn(withEmail: email, password: pasword) { result, error in
           
            if let err = error {
                errorHandler?(err)
            }
        }
    }
    
    func loginAnonymously(errorHandler: ((Error?)->Void)?) {
        Auth.auth().signInAnonymously { [weak self] result, error in
            if let error = error {
                errorHandler?(error)
            } else {
                guard let uid = result?.user.uid else {return}
                self?.uid = uid
            }
        }
    }
    
    func userIsAnonymously() -> Bool {
        guard let user = Auth.auth().currentUser else {return false}
        getProfileDocuments()
        return user.isAnonymous
    }
    
    func logOut() {
        try? Auth.auth().signOut()
        self.uid = ""
        self.userProfile = nil
    }
    
    func removeHandleListener() {
        guard let handle = handle else {return}
        Auth.auth().removeStateDidChangeListener(handle)
        self.handle = nil
    }
    
    func resetPasswordByEmail(email: String, errorHandler: ((Error?)->Void)? ) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            guard let error else {return}
            errorHandler?(error)
        }
    }
    
    func deleteUser(vc: UIViewController, errorHandler: ((Error?)->Void)? ) {
        guard let user = Auth.auth().currentUser else {return}
        if user.providerData.first?.providerID == "apple.com" {
            deleteCurrentAppleUser(vc: vc) { tokenString in
                Auth.auth().revokeToken(withAuthorizationCode: tokenString) { error in
                    errorHandler?(error)
                }
            }
        }
        DatabaseService.shared.deleteProfile(uid: user.uid) { errorHandler?($0) }
        user.delete(completion: { errorHandler?($0) })
        logOut()
    }
    
    ///Check your email - Is already exists.
    func checkEmailIsBusy(email: String, isBusyHandler: ((Bool)->())? = nil) {
        Auth.auth().fetchSignInMethods(forEmail: email) { arrString, error in
            if let error = error {
                self.error = error
                isBusyHandler?(false)
            } else if let arrString = arrString {
                isBusyHandler?(!arrString.isEmpty)
            } else {
                isBusyHandler?(false)
            }
        }
    }
    
//MARK: - Google Sign up
    
    func authenticationWithGoogle(vc: UIViewController, errorHandler: ((Error?)->Void)? = nil ) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            errorHandler?(AuthorizeError.noFoundID)
            return }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.signIn(withPresenting: vc) { result, error in
            guard error == nil else {
                errorHandler?(error)
                return
            }
            guard let user = result?.user else {return}
            guard let idToken = user.idToken?.tokenString else {
                errorHandler?( AuthorizeError.errorToken)
                return
            }
            let accessToken = user.accessToken.tokenString
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: accessToken)
            Auth.auth().signIn(with: credential) { result, error in
                guard error == nil else {
                    errorHandler?(error)
                    return
                }
                guard let result = result else {return}
                let userId = result.user.uid
                self.uid = userId
                
                DatabaseService.shared.documentIsExists(uid: userId) { isExist in
                    if !isExist {
                        let userProfile = UserProfile(name: result.user.displayName ?? "None", email: result.user.email ?? "None", uid: userId )
                        DatabaseService.shared.sendProfileToServer(uid: userId, profile: userProfile) { error in
                            self.error = error
                        }
                    }
                    self.getProfileDocuments()
                }
            }
        }
    }
    
//MARK: - Apple Authentications:
   
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let nonce = currentNonce,
              let appleIDToken = appleIDCredential.identityToken,
              let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            completionResultTokenApple?(.failure(AuthorizeError.errorToken))
            return
        }
        completionStringToken?(idTokenString)
        let token = SignInWithAppleResult(token: idTokenString, nonce: nonce)
        completionResultTokenApple?(.success(token))
        }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        completionResultTokenApple?(.failure(AuthorizeError.cancelAppleAuth))
      }
    
    func signInWithApple(token: SignInWithAppleResult) async throws {
        let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                  idToken: token.token,
                                                  rawNonce: token.nonce)
        let result = try await Auth.auth().signIn(with: credential)
        
        let userId = result.user.uid
        self.uid = userId
        
        DatabaseService.shared.documentIsExists(uid: userId) { isExist in
            if !isExist {
                let userProfile = UserProfile(name: result.user.displayName ?? "None", email: result.user.email ?? "None", uid: userId )
                DatabaseService.shared.sendProfileToServer(uid: userId, profile: userProfile) { error in
                    self.error = error
                }
            }
            self.getProfileDocuments()
        }
    }
    
    func startSignInWithAppleFlow(vc: UIViewController, completion: @escaping (Result<SignInWithAppleResult, Error>) -> Void) {
        
        let appleHelper = SignInAppleIDHelper()
        let nonce = appleHelper.randomNonceString()
        
        currentNonce = nonce
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = appleHelper.sha256(nonce)

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = vc
        authorizationController.performRequests()
        completionResultTokenApple = completion
    }
    
    private func deleteCurrentAppleUser(vc: UIViewController, completion: @escaping (String) -> Void) {
        let appleHelper = SignInAppleIDHelper()
        let nonce = appleHelper.randomNonceString()
        
        currentNonce = nonce
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = appleHelper.sha256(nonce)

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = vc
        authorizationController.performRequests()
        completionStringToken = completion
    }
}

