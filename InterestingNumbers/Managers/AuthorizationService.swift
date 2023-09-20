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
            print(error?.localizedDescription ?? "Not parce error")
        }
    }
    
    var completionResultTokenApple: ((Result<SignInWithAppleResult, Error>)-> Void)?
    var currentNonce: String? //Apple authorization
    var cancellables = Set<AnyCancellable>()
    private var handle: AuthStateDidChangeListenerHandle?
    
    static let shared = AuthorizationService()
    
    private override init() {
        super.init()
        setupFirebaseAuth()
    }
    
    func setupFirebaseAuth() {
        handle = Auth.auth().addStateDidChangeListener {[weak self] auth, user in
            guard let self = self else {return}
            self.sessionState = user == nil ? .loggedOut : .loggedIn
            guard let user = user else {return}
            self.uid = user.uid
            guard !user.isAnonymous else {return}
            self.fetchProfile(uidDocument: self.uid) { error in
                guard let error = error else {return}
                self.error = error
            }
        }
    }
    
    ///Fetch users profile document from server FireStore
    func fetchProfile(uidDocument: String, errorHandler: ((Error?)->Void)? = nil) {
       
        Firestore.firestore().collection(TitleConstants.nameCollection).document(uidDocument).getDocument { [weak self] document, error in
            if let document = document, document.exists {
                do {
                    self?.userProfile = try document.data(as: UserProfile.self)
                } catch {
                    errorHandler?(AuthorizeError.errorParceProfile)
                }
            } else {
                self?.userProfile = nil
                errorHandler?(AuthorizeError.docNotExists)
            }
        }
    }
    
    func signUp(_ email: String, _ pasword: String, profile: UserProfile?, errorHandler: ((Error?)->Void)?) {
        guard let profile = profile else {return}
       
        Auth.auth().createUser(withEmail: email, password: pasword) { [weak self] result, error in
            switch result {
            case .none:
                print("None in signUp in Manager")
            case .some(let result):
                self?.uid = result.user.uid
                self?.sendProfileToServer(profile: profile) { error in
                    guard let error = error else {return}
                    errorHandler?(error)
                }
            }
            if let error = error {
                errorHandler?(error)
            }
        }
    }
    
    func sendProfileToServer(profile: UserProfile,errorHandler: ((Error?)->Void)?) {
        let reference = Firestore.firestore().collection(TitleConstants.nameCollection).document(uid)
        do {
            try reference.setData(from: profile, merge: true)
        } catch {
            errorHandler?(AuthorizeError.sendDataFailed)
        }
    }
    //TODO: - переделать посылку запросов
    func addCountRequest(countRequest: Int, errorHandler: ((Error?)->Void)?) {
        let reference = Firestore.firestore().collection(TitleConstants.nameCollection).document(uid)
        do {
            userProfile?.countRequest = countRequest
            try reference.setData(from: userProfile, merge: true)
        } catch {
            errorHandler?(AuthorizeError.sendDataFailed)
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
        fetchProfile(uidDocument: user.uid)
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
    }
    
    func resetPasswordByEmail(email: String, errorHandler: ((Error?)->Void)? ) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            guard let error else {return}
            errorHandler?(error)
        }
    }
    
    func deleteUser(errorHandler: ((Error?)->Void)? ) {
        Firestore.firestore().collection(TitleConstants.nameCollection).document(self.uid).delete { error in
            guard let error else {return}
            errorHandler?(error)
        }
        
        Auth.auth().currentUser?.delete(completion: { error in
            guard let error else {return}
            errorHandler?(error)
        })
    }
    
    ///Check your email - Is already exists.
    func checkEmailIsBusy(email: String, isBusyHandler: ((Bool)->())? = nil) {
        Auth.auth().fetchSignInMethods(forEmail: email) { arrString, error in
            if let error = error {
                print(error.localizedDescription)
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
                self.documentIsExists(userUID: userId) { value, error in
                    if let error = error {
                        print(error.localizedDescription)
                    } else if !value {
                        let userProfile = UserProfile(name: result.user.displayName ?? "Input your name", email: result.user.email ?? "None", uid: userId )
                        self.sendProfileToServer(profile: userProfile, errorHandler: nil)
                    } else {
                        print("Document already exists")
                    }
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
        documentIsExists(userUID: userId) { value, error in
            if let error = error {
                print(error.localizedDescription)
            } else if !value {
                let userProfile = UserProfile(name: result.user.displayName ?? "Input your name", email: result.user.email ?? "None", uid: userId )
                self.sendProfileToServer(profile: userProfile, errorHandler: nil)
            } else {
                print("Document already exists")
            }
        }
    }
    
    func startSignInWithAppleFlow(vc: UIViewController, completion: @escaping (Result<SignInWithAppleResult, Error>) -> Void) {
        
        let appleHelper = SignInAppleIDHelper()
        let nonce = appleHelper.randomNonceString()
        
        currentNonce = nonce
        completionResultTokenApple = completion
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = appleHelper.sha256(nonce)

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = vc
        authorizationController.performRequests()
    }
    
    func documentIsExists(userUID:String, completion: @escaping ((Bool, Error? )->Void)) {
        Firestore.firestore().collection(TitleConstants.nameCollection).document(userUID).getDocument { [weak self] document, error in
            if let document = document, document.exists {
                do {
                    self?.userProfile = try document.data(as: UserProfile.self)
                    completion(true, nil)
                } catch {
                    completion(false, AuthorizeError.errorParceProfile)
                }
            } else {
                self?.userProfile = nil
                completion(false, nil)
            }
        }
    }
}

