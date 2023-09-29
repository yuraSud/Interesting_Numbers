//
//  DatabaseService.swift
//  Interesting_Numbers
//
//  Created by Yura Sabadin on 20.09.2023.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseCore
import Firebase

final class DatabaseService {
    
    static let shared = DatabaseService()
    private init() {}
    
    private let db = Firestore.firestore()
    private var request = 0
    
    enum FirebaseRefferencies {
        case product
        case profile
        case header
        
        var ref: CollectionReference {
            switch self {
            case .product:
                return Firestore.firestore().collection(TitleConstants.productCollection)
            case .header:
                return Firestore.firestore().collection(TitleConstants.headerModel)
            case .profile:
                return Firestore.firestore().collection(TitleConstants.profileCollection)
            }
        }
    }
    
    ///Fetch users profile document from server FireStore
    func fetchProfile(uid: String, completion: @escaping ((Result<UserProfile?,Error>)->Void)) {
       
        db.collection(TitleConstants.profileCollection).document(uid).getDocument {document, error in
            self.request += 1
            if let document = document, document.exists {
                do {
                    let userProfile = try document.data(as: UserProfile.self)
                    completion(.success(userProfile))
                } catch {
                    completion(.failure(AuthorizeError.errorParceProfile))
                }
            } else {
                completion(.failure(AuthorizeError.docNotExists))
            }
        }
    }
    
    func documentIsExists(uid:String, completion: @escaping ((Bool)->Void)) {
        db.collection(TitleConstants.profileCollection).document(uid).getDocument { document, _ in
            if let document = document, document.exists {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func deleteProfile(uid: String, errorHandler: ((Error?)->Void)? ) {
        FirebaseRefferencies.profile.ref.document(uid).delete { error in
            errorHandler?(error)
        }
    }
    
    func addProduct(product: ProductModel, image: Data, completion: @escaping (Result<String,Error>)->Void) {
        StorageService.shared.uploadFile(id: product.id, image: image) { result in
            switch result {
            case .success(let sizeInfo):
                completion(.success(sizeInfo))
                do {
                    try FirebaseRefferencies.product.ref.document(product.id).setData(from: product)
                } catch let err {
                    completion(.failure(err))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func deleteProduct(product: ProductModel, completion: @escaping (Result<Bool, Error>)->()) {
        StorageService.shared.deleteImage(id: product.id) { error in
            completion(.failure(error))
        }
        FirebaseRefferencies.product.ref.document(product.id).delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
        }
    }
    
    func sendProfileToServer(uid: String, profile: UserProfile, errorHandler: ((Error?)->Void)?) {
        do {
            
            try FirebaseRefferencies.profile.ref.document(uid).setData(from: profile, merge: true)
        } catch {
            errorHandler?(AuthorizeError.sendDataFailed)
        }
    }
    
    func getAllProducts() async throws -> [ProductModel] {
        let qSnapShot = try await FirebaseRefferencies.product.ref.getDocuments().documents
        var arrayProduct = [ProductModel]()
        for value in qSnapShot {
            guard let product = ProductModel(qSnapShot: value) else {return []}
            arrayProduct.append(product)
        }
        return arrayProduct
    }
    
    func getAllHeaders() async throws -> [HeaderSectionModel] {
        let qSnapShot = try await FirebaseRefferencies.header.ref.getDocuments().documents
        var arrayHeaders = [HeaderSectionModel]()
        for value in qSnapShot {
            guard let product = HeaderSectionModel(qSnapShot: value) else {return []}
            arrayHeaders.append(product)
        }
        return arrayHeaders
    }
    
    func addCountRequest(user: UserProfile, errorHandler: ((Error?)->Void)?) {
        let reference = db.collection(TitleConstants.profileCollection).document(user.uid)
        do {
            try reference.setData(from: user, merge: true)
        } catch {
            errorHandler?(AuthorizeError.sendDataFailed)
        }
    }
}
