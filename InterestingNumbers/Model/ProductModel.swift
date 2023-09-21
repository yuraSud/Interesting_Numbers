//
//  ProductModel.swift
//  Interesting_Numbers
//
//  Created by Yura Sabadin on 20.09.2023.
//

import Foundation
import FirebaseFirestore

struct ProductModel: Encodable {
    
    var nameProduct: String
    var cost: String
    var id: String
    
    init(nameProduct: String, cost: String, id: String) {
        self.nameProduct = nameProduct
        self.cost = cost
        self.id = id
    }
    
    init?(qSnapShot: QueryDocumentSnapshot) {
        let data = qSnapShot.data()
        guard let id = data["id"] as? String,
              let cost = data["cost"] as? String,
              let nameProduct = data["nameProduct"] as? String
        else { return nil }
        
        self.nameProduct = nameProduct
        self.cost = cost
        self.id = id
    }
}
