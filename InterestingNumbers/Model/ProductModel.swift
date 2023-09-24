//
//  ProductModel.swift
//  Interesting_Numbers
//
//  Created by Yura Sabadin on 20.09.2023.
//

import Foundation
import FirebaseFirestore

struct ProductModel: Codable {
    
    var nameProduct: String
    var cost: String
    var id: String
    var category: String
    var isFavourite: Bool? = false
    
    init(nameProduct: String, cost: String, id: String, category: String, isFavourite: Bool = false) {
        self.nameProduct = nameProduct
        self.cost = cost
        self.id = id
        self.category = category
        self.isFavourite = isFavourite
    }
    
    init?(qSnapShot: QueryDocumentSnapshot) {
        let data = qSnapShot.data()
        let id = data["id"] as? String
        let cost = data["cost"] as? String
        let nameProduct = data["nameProduct"] as? String
        let category = data["category"] as? String
        let isFavourite = data["isFavourite"] as? Bool
        
        self.nameProduct = nameProduct ?? "Nothin"
        self.cost = cost ?? "0"
        self.id = id ?? UUID().uuidString
        self.category = category ?? "Other"
        self.isFavourite = isFavourite
    }
}
