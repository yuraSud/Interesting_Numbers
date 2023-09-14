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


class AuthorizationService {
    
    @Published var userProfile: UserProfile?
    @Published var sessionState: SessionState = .loggedOut
    @Published var uid = ""
    @Published var error: Error? {
        didSet {
            print(error?.localizedDescription ?? "Not parce error")
        }
    }
    
    var cancellables = Set<AnyCancellable>()
    private var handle: AuthStateDidChangeListenerHandle?
    
    static let shared = AuthorizationService()
    
    private init() {
        setupFirebaseAuth()
    }
    
    func setupFirebaseAuth() {
        handle = Auth.auth().addStateDidChangeListener {[weak self] auth, user in
            guard let self = self else {return}
            self.sessionState = user == nil ? .loggedOut : .loggedIn
            guard let user = user else {return}
            self.uid = user.uid
            guard !user.isAnonymous else {return}
            self.fetchProfile() { error in
                guard let error = error else {return}
                self.error = error
            }
        }
    }
    
    ///Fetch users profile document from server FireStore
    func fetchProfile(errorHandler: ((Error?)->Void)? = nil) {
       
        guard !uid.isEmpty else {
            errorHandler?(AuthorizeError.uid)
            return}
        
        Firestore.firestore().collection(TitleConstants.nameCollection).document(uid).getDocument { [weak self] document, error in
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
       
        Auth.auth().createUser(withEmail: email, password: pasword) { result, error in
            switch result {
            case .none:
                print("None in signUp in Manager")
            case .some(let result):
                self.uid = result.user.uid
                self.sendProfileToServer(profile: profile) { error in
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
            try reference.setData(from: profile)
        } catch {
            errorHandler?(AuthorizeError.sendDataFailed)
        }
    }
    
    func logIn(email: String, pasword: String, errorHandler: ((Error)->Void)?) {
        Auth.auth().signIn(withEmail: email, password: pasword) { result, error in
           
            if let err = error {
                errorHandler?(err)
            }
            switch result {
            case .none:
                print("Password failed")
            case .some(let res):
                print(res.user.email ?? "email")
            }
        }
    }
    
    func loginAnonymously(errorHandler: ((Error?)->Void)?) {
        Auth.auth().signInAnonymously { result, error in
            if let error = error {
                errorHandler?(error)
            } else {
                guard let uid = result?.user.uid else {return}
                self.uid = uid
            }
        }
    }
    
    func userIsAnonymously() -> Bool {
        guard let user = Auth.auth().currentUser else {return false}
            return user.isAnonymous
    }
    
    func logOut() {
        try? Auth.auth().signOut()
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
}
