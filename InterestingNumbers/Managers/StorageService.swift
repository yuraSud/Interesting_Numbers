//
//  StorageService.swift
//  Interesting_Numbers
//
//  Created by Yura Sabadin on 20.09.2023.
//

import Foundation
import FirebaseStorage
import UIKit

final class StorageService {
    static let shared = StorageService()
    private init() {}
    
    private let storage = Storage.storage().reference()
    
    enum Refferencies {
        case product
        case header
        case html
        
        var ref: StorageReference {
            switch self {
            case .product:
                return Storage.storage().reference().child("Products/ProductImages")
            case .header:
                return Storage.storage().reference().child("HeaderImage")
            case .html:
                return Storage.storage().reference().child("Html")
            }
        }
    }
    
    func uploadFile(id: String, image: Data, completion: @escaping (Result<String, Error>) -> Void) {
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        Refferencies.product.ref.child(id).putData(image) { result in
            switch result {
            case .success(let metaData):
                completion(.success("Upload successfully \nSize file is equal = \(metaData.size) bytes"))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func downloadImage(refference: Refferencies, id: String, completion: @escaping (Result<URL,Error>)->()) {
        refference.ref.child(id)
            .downloadURL { result in
                switch result {
                case .success(let url):
                    completion(.success(url))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    func deleteImage(id: String, completion: @escaping (Error)->()) {
        Refferencies.product.ref.child(id).delete { error in
            guard let error else {return}
            completion(error)
        }
    }
    
    func downloadFileHtml(comletion: @escaping (URL)->Void) {
        let fileManager = FileManagerService.instance
        Refferencies.html.ref.listAll { result, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            switch result {
            case .none:
                print("none what is this")
            case .some(let result):
                
                let path = result.items[0].name
                let fullreff = Refferencies.html.ref.child(path) //full path url to download from server
                
                guard let localURLpath = fileManager.getPath(name: path) else {return} //create local path url file to write on device
                fullreff.write(toFile: localURLpath) { result in
                    switch result {
                    case .success(let resultUrl):
                        print("success")
                        comletion(resultUrl) //place where lie html file
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
}
