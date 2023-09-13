//
//  ChoiseNumbersViewController.swift
//  InterestingNumbers
//
//  Created by Yura Sabadin on 11.09.2023.
//

import UIKit
import Firebase
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth


class ChoiseNumbersViewController: UIViewController {
    
    var handle: AuthStateDidChangeListenerHandle?
    let nameLabel = UILabel()
    var uid = ""
    var profile: Profile?

    override func viewDidLoad() {
        super.viewDidLoad()
        setViews()
        setupNavButton()
        setNameLabel()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handle = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            guard let self = self, let user = user else {
                self?.navigationController?.setViewControllers([EnterViewController()], animated: true)
                return}
            let name = user.displayName ?? ""
            let email = user.email ?? ""
            self.nameLabel.text = name + " " + email
            uid = user.uid
            getDocument(uid: uid)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        guard let handle = handle else {return}
//        Auth.auth().removeStateDidChangeListener(handle)
    }
    
    func setNameLabel() {
        nameLabel.frame = CGRect(x: 20, y: 100, width: view.frame.width - 40, height: 100)
        nameLabel.numberOfLines = 0
        view.addSubview(nameLabel)
    }
    
    func setViews() {
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.isHidden = false
    }
    
    func setupNavButton() {
        let button = UIButton(type: .system)
        button.frame = .init(x: 0, y: 0, width: 40, height: 40)
        button.titleLabel?.sizeToFit()
        button.titleLabel?.font = .boldSystemFont(ofSize: 20)
        button.clipsToBounds = true
        button.setTitle("Y", for: .normal)
        button.layer.cornerRadius = button.bounds.size.width / 2
        button.backgroundColor = .systemMint
        button.addTarget(self, action: #selector(logOut), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
    }
    
    @objc func logOut() {
        
        let alertController = UIAlertController(title: "Do you want Log out?", message: nil, preferredStyle: .actionSheet)
        
        let actionLogOut = UIAlertAction(title: "Log Out", style: .default) { _ in
            //log out
            self.singOut()
            self.navigationController?.setViewControllers([EnterViewController()], animated: true)
        }
        
        let addSex = UIAlertAction(title: "Add Sex", style: .default) { _ in
            let profileMerge = Profile(age: 60, sex: .male)
            do {
                try Firestore.firestore().collection("users").document(self.uid).setData(from: profileMerge, merge: true)
            } catch {
                print("not added profile")
            }
            self.getDocument(uid: self.uid)
        }
        
        let deleteDataUser = UIAlertAction(title: "Delete Data User", style: .default) { _ in
            Firestore.firestore().collection("users").document(self.uid).delete { error in
                guard let error else {return}
                print(error.localizedDescription)
            }
            self.getDocument(uid: self.uid)
            print("Delete document")
        }
        
        let deleteUser = UIAlertAction(title: "Delete Account", style: .default) { _ in
            Auth.auth().currentUser?.delete(completion: { error in
                guard let error else {return}
                print(error.localizedDescription)
            })
            self.navigationController?.setViewControllers([EnterViewController()], animated: true)
                print("finish Delete account")
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            self.getDocument(uid: self.uid)
        }
        alertController.addAction(actionLogOut)
        alertController.addAction(addSex)
        alertController.addAction(deleteDataUser)
        alertController.addAction(deleteUser)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
    
    func singOut() {
        do {
          try Auth.auth().signOut()
        } catch let signOutError as NSError {
          print("Error signing out", signOutError)
        }
    }
    
    func getDocument(uid: String) {
//        Firestore.firestore().collection("users").document(uid).getDocument { document, error in
//            if let document = document, document.exists {
//                let r = document.data()
//                let name = r?[ProfileEnum.name.rawValue] as? String
//                let age = r?[ProfileEnum.age.rawValue] as? Int
//                let sex = r?[ProfileEnum.sex.rawValue] as? Sex
//                self.nameLabel.text?.append("\n\(name ?? ""), \(age ?? 0)\n\(sex?.rawValue ?? "Not find data")")
//            } else {
//                print("not ex documents")
//            }
//        }
//        Firestore.firestore().collection("users").getDocuments { snap, err in
//            if let err = err {
//                print(err.localizedDescription)
//            } else {
//                guard let snap = snap else {return}
//                for i in snap.documents {
//                    print(i.documentID)
//                    do{
//                        print( try i.data(as: Profile.self).name)
//
//                    } catch {
//                        print("error loop")
//                    }
//                }
//            }
//
//        }
        
        Firestore.firestore().collection("users").document(uid).getDocument(as: Profile.self) { result in
            switch result {
                
            case .success(let profile):
                self.profile = profile
                self.nameLabel.text? = "\n\(profile.name ?? "not"), \(profile.age ?? 000)\n\(profile.sex?.rawValue ?? "Not find data")"
            case .failure(let err):
                self.nameLabel.text? = "data not find"
                print(err.localizedDescription)
            }
        }
    }
    
    
}
