//
//  CategoriesProduct.swift
//  Interesting_Numbers
//
//  Created by Yura Sabadin on 22.09.2023.
//

import Foundation
import FirebaseFirestore

struct CategoriesProduct: Codable {
    var categories: [String]
    
    init( categories: [String])  {
        self.categories = categories
    }
    
    init?(qSnapShot: QueryDocumentSnapshot) {
        let data = qSnapShot.data()
        let categories = data["categories"] as? [String]
        
        self.categories = categories ?? ["Nothin"]
    }
}
