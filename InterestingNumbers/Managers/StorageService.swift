//
//  StorageService.swift
//  Interesting_Numbers
//
//  Created by Yura Sabadin on 20.09.2023.
//

import Foundation
import FirebaseStorage
import UIKit

class StorageService {
    static let shared = StorageService()
    private init() {}
    
    private let storage = Storage.storage().reference()
   
    private var productRefference: StorageReference { storage.child("Products/ProductImages")}
    
    private var htmlRef: StorageReference { storage.storage.reference(forURL: "gs://interestingnumberssud.appspot.com/Html")}
    
    func uploadFile(id: String, image: Data, completion: @escaping (Result<String, Error>) -> Void) {
        let metaData = StorageMetadata()
        metaData.contentType = "image/png"
        productRefference.child(id).putData(image) { result in
            switch result {
            case .success(let metaData):
                completion(.success("Upload successfully \nSize file is equal = \(metaData.size) bytes"))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func downloadImage(id: String, completion: @escaping (Result<Data,Error>)->()) {
        productRefference.child(id).getData(maxSize: (2*1024*1024)) { result in
            switch result {
            case .success(let data):
                completion(.success(data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func deleteImage(id: String, completion: @escaping (Error)->()) {
        productRefference.child(id).delete { error in
            guard let error else {return}
            completion(error)
        }
    }
/*
    func downloadFileHtml() {
        htmlRef.listAll { result, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            switch result {
            case .none:
                print("none what is this")
            case .some(let result):
                var path = result.items[0].name
                let fullreff = self.htmlRef.child(path)
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let localURL = documentsURL.appendingPathComponent(path)
                let downloadTask = fullreff.write(toFile: localURL)
                
                self.pushFile(localURL)
                
            }
        }
    }
    func pushFile(_ destination: URL) {
        var finalURL = destination.absoluteString
        
        DispatchQueue.main.async {
            if let url = URL(string: finalURL) {
                if #available(iOS 10, *){
                    UIApplication.shared.open(url)
                }else{
                    UIApplication.shared.openURL(url)
                }
                
            }
        }
    }
 */
    
}
