//
//  DatabaseService.swift
//  Interesting_Numbers
//
//  Created by Yura Sabadin on 20.09.2023.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class DatabaseService {
    
    static let shared = DatabaseService()
    private let db = Firestore.firestore()
    
    private var productsRef: CollectionReference {
        db.collection(TitleConstants.productCollection)
    }
    
    private var profilesRef: CollectionReference {
        db.collection(TitleConstants.profileCollection)
    }
    
    private init() {}
    
    func deleteProfile(uid: String, errorHandler: ((Error?)->Void)? ) {
        profilesRef.document(uid).delete { error in
            guard let error else {return}
            errorHandler?(error)
        }
    }
        
        func addProduct(product: ProductModel, image: Data, completion: @escaping (Result<String,Error>)->Void) {
            StorageService.shared.uploadFile(id: product.id, image: image) { result in
                switch result {
                case .success(let sizeInfo):
                    completion(.success(sizeInfo))
                    do {
                        try self.productsRef.document(product.id).setData(from: product)
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
            productsRef.document(product.id).delete { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(true))
                }
            }
        }
        
        func sendProfileToServer(uid: String, profile: UserProfile, errorHandler: ((Error?)->Void)?) {
            do {
                try profilesRef.document(uid).setData(from: profile, merge: true)
            } catch {
                errorHandler?(AuthorizeError.sendDataFailed)
            }
        }
        
        func getAllProducts() async throws -> [ProductModel] {
            let qSnapShot = try await productsRef.getDocuments().documents
            var arrayProduct = [ProductModel]()
            for value in qSnapShot {
                guard let product = ProductModel(qSnapShot: value) else {return []}
                arrayProduct.append(product)
            }
            return arrayProduct
        }
        
    }
